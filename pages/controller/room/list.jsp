<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能控制-房间控制</title>

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
                <span class="breadcrumb-active">房间控制</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;房间信息总览</span>
                    </div>
                    <div class="panel__body">
                        <div class="panel-toolbar">
                            <div class="ui-search">
                                <label for="" class="search-label">快速检索：</label>
                                <div class="search__item">
                                    <select name="" id="search_select_building" class="ui-form-select">
                                        <option value="0">请选择楼宇</option>
                                    </select>
                                </div>
                                <div class="search__item">
                                    <select name="" id="search_select_level" class="ui-form-select">
                                        <option value="0">请选择楼层</option>
                                    </select>
                                </div>
                                <a href="javascript:void(0);" class="ui-button ui-button-sm" id="search_submit"><i class="fa fa-search"></i>&nbsp;检索</a>
                            </div>
                        </div>
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="一键开灯" id="multi_light_open"><i class="fa fa-lightbulb-o"></i>&nbsp;一键开灯</a>
                                <a href="javascript:void(0);" class="ui-button ui-button-sm" title="一键关灯" id="multi_light_close"><i class="fa fa-lightbulb-o"></i>&nbsp;一键关灯</a>
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="一键开启插座" id="multi_socket_open"><i class="fa fa-plug"></i>&nbsp;一键开启插座</a>
                                <a href="javascript:void(0);" class="ui-button ui-button-sm" title="一键关闭插座" id="multi_socket_close"><i class="fa fa-plug"></i>&nbsp;一键关闭插座</a>
                            </div>
                            <table class="ui-table" id="room_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width:30px;">序号</th>
                                        <th>楼宇名称</th>
                                        <th>楼层名称</th>
                                        <th>房间名称</th>
                                        <th style="width:80px;">已开启设备</th>
                                        <th style="width:80px;">设备总数</th>
                                        <th style="width:120px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="room_list_paging"></div>
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
    SidebarMenu.init('controller', 'room');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js'),
    SelectDict = require('/components/select-option/service.js');

var SEARCH_BUILDING_NO = Url('?building_no') || null,
    SEARCH_BUILDING_LEVEL_NO = Url('?level_no') || null;

var MULTI_SWITCHER_HANDLER = null;
function multi_switch(_status, _ids, _type, _callback){
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
        'content': '<p class="confirm-cnt">您是否需要'+status_cn+'这'+ _ids.length +'个选择项么？</p>',
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
                bizType: 2,
                deviceType: _type
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

var Room_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_room_no, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
            if(__item['room_no']==_room_no){
                item = __item;
                $.isFunction(_callback) && _callback(__index);
                return false;
            }
        });

        return item;
    }

    var get_resources_handler = null;
    function get_resources(_page_next, _building_no, _building_level_no, _success_callback){
        if(get_resources_handler!==null){
            return false;
        }

        render_loading();

        var page_next = _page_next || page_no;
        page_next = (page_next<=0) ? 1 : ((page_total===null) || (page_next<=page_total)) ? page_next : page_total;
        page_no = page_next;

        var resource_params = {
            pageNo: page_next,
            pageSize: page_limit
        };
        if(_building_no!==null){
            resource_params['building_no'] = _building_no
        }
        if(_building_level_no!==null){
            resource_params['buildingLevel_no'] = _building_level_no
        }

        get_resources_handler = $.getJSON('/school/V1/ControllerService/_findControllerRoomPage', resource_params).done(function(_data, _status, _xhr){
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
                '<td colspan="8">',
                    '<div class="cell__placeholder">',
                        '<i class="fa fa-spinner fa-spin"></i>&nbsp;数据加载中...',
                    '</div>',
                '</td>'
            ].join(''));
        }
    }
    function render_error(){
        $content.html([
            '<td colspan="8">',
                '<div class="cell__placeholder error">',
                    '<i class="fa fa-info-circle"></i>&nbsp;数据加载失败，<a href="javascript:void(0);" class="placeholder-link J_btn_reload">请再试一次</a>！',
                '</div>',
            '</td>'
        ].join(''));
    }
    function render_data(_result, _offset_base){
        if(_result===undefined || _result.length===0){
            $content.html([
                '<td colspan="8">',
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="room_item_'+ __item['room_no'] +'">',
                    '<td><input type="checkbox" class="J_select_one" data-room-no="'+ __item['room_no'] +'"></td>',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td class="J_build_name">'+ __item['building_name'] +'</td>',
                    '<td class="J_floor_name">'+ __item['room_level'] +'</td>',
                    '<td class="J_room_name">'+ __item['room_name'] +'</td>',
                    '<td>'+ __item['device_open_count'] +'</td>',
                    '<td>'+ __item['device_count'] +'</td>',
                    '<td>',
                        '<a href="/school/route/controller/room/detail?no='+ __item['room_no'] +'&list_path='+ window.encodeURIComponent(Url()) +'&name='+ window.encodeURI(__item['building_name']+'-'+__item['room_level']+'-'+__item['room_name']) +'" class="ui-button ui-button-sm" title="设备控制"><i class="fa fa-gear"></i>&nbsp;设备控制</a>',
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
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

            get_resources(page_no, _params['building_no'], _params['building_level_no'], function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('room_list_paging', {
                    pageNo:  _data['pageNo'],
                    totalPages: _data['totalPages'],
                    pageSize: _data['pageSize'],
                    records: _data['records']
                })
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
                    result.push($(this).data('room-no'));
                });
            }
            return result;
        }
    };
})();

Room_list.init('room_list', {
    'page_no': Url('?pageNo') || 1,
    'page_limit': Url('?pageSize') || 10,
    'building_no': SEARCH_BUILDING_NO,
    'building_level_no': SEARCH_BUILDING_LEVEL_NO
});

$('#multi_light_open').on('click', function(){
    multi_switch(true, Room_list.get_select_result(), 'switch');
});
$('#multi_light_close').on('click', function(){
    multi_switch(false, Room_list.get_select_result(), 'switch');
});
$('#multi_socket_open').on('click', function(){
    multi_switch(false, Room_list.get_select_result(), 'socket');
});
$('#multi_socket_close').on('click', function(){
    multi_switch(false, Room_list.get_select_result(), 'socket');
});

var $search_select_building = $('#search_select_building'),
    $search_select_level = $('#search_select_level');
SelectDict.get({
    bizType: 'building'
}, function(_data){
    var options = [];
    $.each(_data, function(_i, _building_option){
        options.push('<option value="'+ _building_option['building_no'] +'">'+ _building_option['building_name'] +'</option>')
    });
    $search_select_building
        .append(options.join(''))
        .on('change', function(){
            var building_no = $(this).val(),
                options = ['<option value="0">请选择楼层</option>'];
            if(parseInt(building_no, 10)===0){
                $search_select_level.html(options.join('')).val(0);
            }else{
                SelectDict.get({
                    bizType: 'buildingLevel',
                    no: building_no
                }, function(_data){
                    $.each(_data, function(_i, _building_level_option){
                        options.push('<option value="'+ _building_level_option['level_no'] +'">'+ _building_level_option['level_name'] +'</option>')
                    });
                    $search_select_level.html(options.join('')).val(0);
                });
            }
        });

    // init search select
    if(SEARCH_BUILDING_NO!==null){

        $search_select_building.val(SEARCH_BUILDING_NO);

        SelectDict.get({
            bizType: 'buildingLevel',
            no: SEARCH_BUILDING_NO
        }, function(_data){
            var options = ['<option value="0">请选择楼层</option>'];
            $.each(_data, function(_i, _building_level_option){
                options.push('<option value="'+ _building_level_option['level_no'] +'">'+ _building_level_option['level_name'] +'</option>')
            });
            $search_select_level.html(options.join('')).val(SEARCH_BUILDING_LEVEL_NO || 0);
        });
    }
});

$('#search_submit').on('click', function(){
    var building_no = parseInt($search_select_building.val(), 10),
        building_level_no = parseInt($search_select_level.val(), 10),
        search_url = Url('path');

    if(building_no!==0){
        search_url += '?building_no=' + building_no;

        if(building_level_no!==0){
            search_url += '&level_no=' + building_level_no;
        }
    }

    window.location.href = search_url;
});

</script>

</body>
</html>
