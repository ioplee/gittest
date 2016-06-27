<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能控制-楼宇控制-开关控制</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="../controller.scss" charset="utf-8">

    <script src="assets/scripts/utils.js" charset="utf-8"></script>
    <script src="assets/vendors/mod/mod.js" charset="utf-8"></script>
    <script src="assets/vendors/jquery/dist/jquery.js" charset="utf-8"></script>
</head>
<body>
    <link rel="import" href="/components/header/header.html?__inline">
    <!--// component/header -->

    <div class="body-container">
        <div class="body-container__sidebar">
            <link rel="import" href="/components/sidebar/sidebar.html?__inline">
            <!--// component/sidebar -->
        </div>
        <div class="body-container__main">
            <div class="breadcrumb">
                <i class="fa fa-dashboard"></i>
                <a href="#" class="breadcrumb-link">总控制台</a>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">智能控制</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">楼层控制</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">开关</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel-navigator">
                        <a href="./plug" class="navigator__item actived"><i class="fa fa-cubes"></i>&nbsp;开关</a>
                        <a href="./socket" class="navigator__item"><i class="fa fa-plug"></i>&nbsp;插座</a>
                    </div>
                    <div class="panel__body">
                        <!-- <div class="panel-toolbar">
                            <div class="ui-search-group">
                                <label for="" class="search-label">快速检索：</label>
                                <div class="search__item_first">
                                    <select name="" id="" class="ui-form-select J_ui_select">
                                        <option value="0">请选择楼宇</option>
                                        <option value="1">1号楼</option>
                                        <option value="2">2号楼</option>
                                        <option value="3">3号楼</option>
                                    </select>
                                </div>
                                <input type="text" class="ui-input search__item" value="" placeholder="请输入楼宇名称">
                                <a href="javascript:void(0);" class="ui-button ui-button-sm search__item_last"><i class="fa fa-search"></i></a>
                            </div>
                        </div> -->
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="一键全开" id="floor_plug_open_multi"><i class="fa fa-toggle-on"></i>&nbsp;一键全开</a>
                                <a href="javascript:void(0);" class="ui-button ui-button-sm" title="一键全关" id="floor_plug_close_multi">一键全关&nbsp;<i class="fa fa-toggle-off"></i></a>
                            </div>
                            <table class="ui-table" id="floor_plug_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width:30px;">序号</th>
                                        <th>楼宇名称</th>
                                        <th>楼层名称</th>
                                        <th style="width:100px;">定时打开</th>
                                        <th style="width:100px;">定时关闭</th>
                                        <th style="width:80px;">开启数量</th>
                                        <th style="width:80px;">关闭数量</th>
                                        <th style="width:120px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="floor_plug_list_paging"></div>
                    </div>
                    <!--// .panel__body -->
                </div>
                <!--// .ui-panel -->
            </div>
            <!--// .body-content__wrapper -->
        </div>
    </div>

    <link rel="import" href="/components/footer/footer.html?__inline">
    <!--// component/footer -->

<script>
require.async(['/components/header/header.js', '/components/sidebar/sidebar.js'], function(HeaderMenu, SidebarMenu){
    SidebarMenu.init('controller', 'floor');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js');

var MULTI_SWITCHER_HANDLER = null;
function multi_switch(_status, _ids, _callback){
    if(MULTI_SWITCHER_HANDLER!==null){
        return false;
    }
    if(!_ids || _ids.length===0){
        ArtDialog({
            'skin': 'dialog-confirm',
            'title': '温馨提示',
            'content': '<p class="confirm-cnt">请先选择需要操作的记录!</p>',
            'modal': true,
            'okValue': "确定",
            'ok': $.noop
        }).show();
        return false;
    }
    var status_cn = !_status ? '关闭' : '开启',
        status_code = !_status ? 'OFF' : 'ON';
    ArtDialog({
        'skin': 'dialog-confirm',
        'title': '温馨提示',
        'content': '<p class="confirm-cnt">您是否需要'+status_cn+'这'+ _ids.length +'条记录？</p>',
        'statusbar': [
            '<div class="dialog-form-tip danger">&nbsp;</div>'
        ].join(''),
        'modal': true,
        'okValue': "确定",
        'ok': function(){
            var dialog = this;

            dialog.button([
                    {
                        id: 'ok',
                        value: '正在处理...',
                        autofocus: true,
                        disabled: true
                    }
                ]);

            MULTI_SWITCHER_HANDLER = $.post('/school/V1/ControllerService/_deviceController', {
                ControllerStatus: status_code,
                no: _ids.join(','),
                bizType: 1,
                deviceType: 'switch'
            }).done(function(_data, _status, _xhr){
                if(parseInt(_data['code'], 10)===0){
                    dialog
                        .statusbar([
                            '<div class="dialog-form-tip success">',
                                '<i class="fa fa-check-circle"></i>&nbsp;操作成功！',
                            '</div>'
                        ].join(''))
                        .button([
                            {
                                value: '关闭',
                                autofocus: true,
                                callback: function(){
                                    $.isFunction(_callback) && _callback();
                                    window.location.reload();
                                    return false;
                                }
                            }
                        ]);
                }else{
                    dialog
                        .statusbar([
                            '<div class="dialog-form-tip danger">',
                                '<i class="fa fa-info-circle"></i>&nbsp;',
                                _data['msg'],
                            '</div>'
                        ].join(''))
                        .button([
                            {
                                value: '关闭',
                                autofocus: true,
                                callback: function(){
                                    return true;
                                }
                            }
                        ]);
                }
            }).fail(function(_xhr, _status, _error) {
                dialog
                    .statusbar([
                            '<div class="dialog-form-tip danger">',
                                '<i class="fa fa-info-circle"></i>&nbsp;网络异常，请再试一次',
                            '</div>'
                        ].join(''))
                    .button([
                            {
                                value: '关闭',
                                autofocus: true,
                                callback: function(){
                                    return true;
                                }
                            }
                        ]);
            }).always(function(_data, _status, _error) {
                MULTI_SWITCHER_HANDLER.abort();
                MULTI_SWITCHER_HANDLER = null;
            });
            return false;
        },
        cancelValue: '取消'
    }).show();
}

var Floor_plug_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_level_no, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
            if(__item['level_no']==_level_no){
                item = __item;
                $.isFunction(_callback) && _callback(__index);
                return false;
            }
        });

        return item;
    }

    var get_resources_handler = null;
    function get_resources(_page_next, _success_callback){
        if(get_resources_handler!==null){
            return false;
        }
        var page_next = _page_next || page_no;
        page_next = (page_next<=0) ? 1 : ((page_total===null) || (page_next<=page_total)) ? page_next : page_total;
        page_no = page_next;

        render_loading();

        get_resources_handler = $.getJSON('/school/V1/ControllerService/_findControllerBuildingLevelPage', {
            deviceType: 'switch',
            pageNo: page_next,
            pageSize: page_limit
        }).done(function(_data, _status, _xhr){
            if(parseInt(_data['code'], 10)===0){
                page_no = _data['pageNo'];
                page_limit = _data['pageSize'];
                page_total = _data['totalPages'];
                records_length = _data['records'];

                data = _data;

                render_data(_data['result'], (_data['pageNo']-1)*_data['pageSize']);

                $.isFunction(_success_callback) && _success_callback(_data);
            }else{
                render_error()
            }
        }).fail(function(_xhr, _status, _error) {
            render_error()
        }).always(function(_data, _status, _error) {
            get_resources_handler.abort();
            get_resources_handler = null;
        });
    }

    function render_loading(){
        if($container!==null && $container.length){
            $content.html([
                '<td colspan="9">',
                    '<div class="cell__placeholder">',
                        '<i class="fa fa-spinner fa-spin"></i>&nbsp;数据加载中...',
                    '</div>',
                '</td>'
            ].join(''));
        }
    }
    function render_error(){
        $content.html([
            '<td colspan="9">',
                '<div class="cell__placeholder error">',
                    '<i class="fa fa-info-circle"></i>&nbsp;数据加载失败，<a href="javascript:void(0);" class="placeholder-link J_btn_reload">请再试一次</a>！',
                '</div>',
            '</td>'
        ].join(''));
    }
    function render_data(_result, _offset_base){
        if(_result===undefined || _result.length===0){
            $content.html([
                '<td colspan="9">',
                    '<div class="cell__placeholder">',
                        '<i class="fa fa-info-circle"></i>&nbsp;暂时没有数据',
                    '</div>',
                '</td>'
            ].join(''));
            return;
        }
        var tpl = [];
        $.each(_result, function(__index, __item){
            tpl.push([
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="level_item_'+ __item['level_no'] +'">',
                    '<td><input type="checkbox" class="J_select_one" data-level-no="'+ __item['level_no'] +'"></td>',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td class="J_build_name">'+ __item['building_name'] +'</td>',
                    '<td class="J_floor_name">'+ __item['room_level'] +'</td>',
                    '<td>'+ __item['openTime'] +'</td>',
                    '<td>'+ __item['closetime'] +'</td>',
                    '<td class="J_item_open_num ui-text-success">'+ __item['openNum'] +'</td>',
                    '<td class="J_item_close_num ui-text-danger">'+ __item['closeNum'] +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button-switcher J_btn_switcher" data-level-no="'+ __item['level_no'] +'">',
                            '<span class="switcher__btn J_btn_switcher_on'+ (((parseInt(__item['closeNum'], 10)===0)&&(parseInt(__item['openNum'], 10)!==0))?' actived':'') +'" title="全开"><i class="fa fa-toggle-on"></i>&nbsp;全开</span>',
                            '<span class="switcher__btn J_btn_switcher_off'+ (((parseInt(__item['openNum'], 10)===0)&&(parseInt(__item['closeNum'], 10)!==0))?' actived':'') +'" title="全关">全关&nbsp;<i class="fa fa-toggle-off"></i></span>',
                        '</a>',
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }
    function update_item(_level_no, _data){
        var $item = $('#level_item_'+_level_no);
        if($item.length){
            $item.find('td.J_item_open_num').eq(0).html(_data['openNum']);
            $item.find('td.J_item_close_num').eq(0).html(_data['closeNum']);

            // update data
            find_by_no(_level_no, function(_index){
                data['result'][_index]['openNum'] = _data['openNum'];
                data['result'][_index]['closeNum'] = _data['closeNum'];
            })
        }
    }

    function check_select_all(){
        var $selects = $content.find('input.J_select_one');
        return ($selects.filter(":checked").length === $selects.length) ? true : false;
    }

    return {
        init: function(_$table_id, _params){
            $container = $('#'+_$table_id);
            $content = $container.children('tbody').eq(0);
            page_no = _params['page_no'];
            page_limit = _params['page_limit'];

            get_resources(page_no, function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('floor_plug_list_paging', {
                    pageNo:  _data['pageNo'],
                    totalPages: _data['totalPages'],
                    pageSize: _data['pageSize'],
                    records: _data['records']
                })
            });

            // 绑定单个开关切换事件
            $content.on('click.delete', 'a.J_btn_switcher', function(e){
                var class_name = e.target.className;
                if(~class_name.indexOf('on')){
                    multi_switch(true, [$(this).data('level-no')]);
                }else if(~class_name.indexOf('off')){
                    multi_switch(false, [$(this).data('level-no')]);
                }
            });

            // 绑定单选事件
            $content.on('click.delete', 'input.J_select_one', function(){
                $container.find('input.J_select_all').prop("checked", check_select_all());
            });

            // 绑定全选事件
            $container.on('click.delete', 'input.J_select_all', function(){
                $content.find('input.J_select_one').prop("checked", this.checked);
            });

            $content.on('click.edit', 'a.J_btn_reload', function(){
                window.location.reload();
            });
        },
        get_select_result: function (){
            var $selects = $content.find('input.J_select_one').filter(":checked"),
                result = [];
            if($selects.length){
                $selects.each(function(){
                    result.push($(this).data('level-no'));
                });
            }
            return result;
        }
    };
})();

Floor_plug_list.init('floor_plug_list', {
    page_no: Url('?pageNo') || 1,
    page_limit: Url('?pageSize') || 10
});


$('#floor_plug_open_multi').on('click', function(){
    multi_switch(true, Floor_plug_list.get_select_result());
});
$('#floor_plug_close_multi').on('click', function(){
    multi_switch(false, Floor_plug_list.get_select_result());
});
</script>

</body>
</html>
