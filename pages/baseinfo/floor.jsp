<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能控制-基础配置-楼层</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="./baseinfo.scss" charset="utf-8">

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
                <span class="breadcrumb-active">基础配置</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">楼层</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;楼层列表</span>
                    </div>
                    <div class="panel__body">
                        <!-- <div class="panel-toolbar">
                            <div class="ui-search-group">
                                <label for="" class="search-label">快速检索：</label>
                                <div class="search__item_first">
                                    <select name="" id="" class="ui-form-select J_ui_select">
                                        <option value="0">请选择楼层</option>
                                        <option value="1">1号楼</option>
                                        <option value="2">2号楼</option>
                                        <option value="3">3号楼</option>
                                    </select>
                                </div>
                                <input type="text" class="ui-input search__item" value="" placeholder="楼层检索">
                                <a href="javascript:void(0);" class="ui-button ui-button-sm search__item_last"><i class="fa fa-search"></i></a>
                            </div>
                        </div> -->
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="新增" id="level_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                            </div>
                            <table class="ui-table" id="level_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width: 30px;">序号</th>
                                        <th>楼宇名称</th>
                                        <th>楼层名称</th>
                                        <th>描述</th>
                                        <th style="width: 60px;">状态</th>
                                        <th style="width: 80px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="level_list_paging"></div>
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
    SidebarMenu.init('baseinfo', 'floor');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js'),
    SelectDict = require('/components/select-option/service.js');

var Floor_list = (function(){
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

        get_resources_handler = $.getJSON('/school/V1/BaseDataInfoService/_findPage', {
            bizType: 'buildingLevel',
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
                '<td colspan="7">',
                    '<div class="cell__placeholder">',
                        '<i class="fa fa-spinner fa-spin"></i>&nbsp;数据加载中...',
                    '</div>',
                '</td>'
            ].join(''));
        }
    }
    function render_error(){
        $content.html([
            '<td colspan="7">',
                '<div class="cell__placeholder error">',
                    '<i class="fa fa-info-circle"></i>&nbsp;数据加载失败，<a href="javascript:void(0);" class="placeholder-link J_btn_reload">请再试一次</a>！',
                '</div>',
            '</td>'
        ].join(''));
    }
    function render_data(_result, _offset_base){
        if(_result===undefined || _result.length===0){
            $content.html([
                '<td colspan="7">',
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
                    '<td><input type="checkbox" class="J_select_one" data-building-no="'+ __item['level_no'] +'"></td>',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td class="J_item_building_name">'+ __item['building_name'] +'</td>',
                    '<td class="J_item_name">'+ __item['level_name'] +'</td>',
                    '<td class="J_item_memo">'+ (__item['memo'] || '&nbsp;') +'</td>',
                    '<td class="J_item_status">'+ ((parseInt(__item['level_status'], 10)===0) ? '有效' : '无效') +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="编辑" data-building-no="'+ __item['level_no'] +'"><i class="fa fa-edit"></i>&nbsp;编辑</a>',
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }
    function update_item(_level_no, _data){
        var $item = $('#level_item_'+_level_no);
        if($item.length){
            $item.find('td.J_item_building_name').eq(0).html(_data['building_name']);
            $item.find('td.J_item_name').eq(0).html(_data['level_name']);
            $item.find('td.J_item_memo').eq(0).html(_data['memo']);
            $item.find('td.J_item_status').eq(0).html((parseInt(_data['level_status'], 10)===0) ? '有效' : '无效');

            // update data
            find_by_no(_level_no, function(_index){
                data['result'][_index]['level_name'] = _data['level_name'];
                data['result'][_index]['memo'] = _data['memo'];
                data['result'][_index]['level_status'] = _data['level_status'];
                data['result'][_index]['building_no'] = _data['building_no'];
                data['result'][_index]['building_name'] = _data['building_name'];
            })
        }
    }
    function delete_item(_level_no){
        var $item = $('#level_item_'+_level_no);
        if($item.length){
            $item.addClass('table__tr_deleted');

            // update data
            find_by_no(_level_no, function(_index){
                data['result'].splice(_index, 1);
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
                (!!_data['result'] && _data['result'].length>0) && Paging.init('level_list_paging', {
                    pageNo:  _data['pageNo'],
                    totalPages: _data['totalPages'],
                    pageSize: _data['pageSize'],
                    records: _data['records']
                })
            });

            // 绑定编辑事件
            $content.on('click.edit', 'a.J_btn_edit', function(){
                var item_data = find_by_no($(this).data('building-no'));

                var $level_name = null,
                    $level_memo = null,
                    $level_status = null,
                    $building_select = null;

                var edit_handler = null;
                function check(){
                    return ($.trim($level_name.val()).length!==0) && (($building_select.val()+'')!=='0');
                }

                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '编辑楼层信息',
                    'content': [
                        '<div class="">',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*楼层编号:</label>',
                                '<span class="group__text">'+ item_data['level_no'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*所属楼宇:</label>',
                                '<select class="ui-select group__control J_dialog_building_select">',
                                    '<option value="0">请选择楼宇</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*楼层名称:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_level_name" value="'+ item_data['level_name'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">楼层描述:</label>',
                                '<textarea class="ui-input group__control J_dialog_level_memo">'+ (item_data['memo']||'&nbsp;') +'</textarea>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">楼层状态:</label>',
                                '<select class="ui-select group__control J_dialog_level_status">',
                                    '<option value="0">有效</option>',
                                    '<option value="1">无效</option>',
                                '</select>',
                            '</div>',
                        '</div>'
                    ].join(''),
                    'statusbar': [
                        '<div class="dialog-form-tip danger">&nbsp;</div>'
                    ].join(''),
                    'ok': function(){
                        var dialog = this;

                        if(edit_handler!==null){
                            return false;
                        }
                        if(!check()){
                            dialog.statusbar([
                                '<div class="dialog-form-tip danger">',
                                    '<i class="fa fa-info-circle"></i>&nbsp;请确认*必填字段',
                                '</div>'
                            ].join(''));
                            return false;
                        }

                        dialog.title('正在提交...');
                        var update_params = {
                            bizType: 'buildingLevel',
                            level_name: $level_name.val(),
                            memo: $level_memo.val(),
                            level_status: $level_status.val(),
                            buildingLevel_no: item_data['level_no'],
                            building_no: $building_select.val()
                        };
                        edit_handler = $.post('/school/V1/BaseDataInfoService/_modifyRecord', update_params).done(function(_data, _status, _xhr){
                            if(parseInt(_data['code'], 10)===0){
                                update_item(
                                    item_data['level_no'],
                                    $.extend({}, update_params,
                                        {
                                            building_name: $building_select.children('option[value=\''+ update_params['building_no'] +'\']').text()
                                        }
                                    )
                                );
                                dialog.title('修改成功');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip success">',
                                        '<i class="fa fa-check-circle"></i>&nbsp;修改成功！',
                                    '</div>'
                                ].join(''));
                                dialog.button([
                                    {
                                        value: '关闭',
                                        autofocus: true
                                    }
                                ]);
                            }else{
                                dialog.title('编辑楼层信息');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip danger">',
                                        '<i class="fa fa-info-circle"></i>&nbsp;',
                                        _data['msg'],
                                    '</div>'
                                ].join(''));
                            }
                        }).fail(function(_xhr, _status, _error) {
                            dialog.title('编辑楼层信息');
                            dialog.statusbar([
                                '<div class="dialog-form-tip danger">',
                                    '<i class="fa fa-info-circle"></i>&nbsp;网络异常，请再试一次',
                                '</div>'
                            ].join(''));
                        }).always(function(_data, _status, _error) {
                            edit_handler.abort();
                            edit_handler = null;
                        });
                        return false;
                    },
                    'okValue': '确定',
                    onshow: function(){
                        var dialog = this;
                        $level_name = $(this.node).find('input.J_dialog_level_name').eq(0);
                        $level_memo = $(this.node).find('textarea.J_dialog_level_memo').eq(0);
                        $level_status = $(this.node).find('select.J_dialog_level_status').eq(0);
                        $building_select = $(this.node).find('select.J_dialog_building_select').eq(0);

                        SelectDict.get({
                            bizType: 'building'
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _building_option){
                                options.push('<option value="'+ _building_option['building_no'] +'">'+ _building_option['building_name'] +'</option>')
                            });
                            $building_select.append(options.join('')).val(item_data['building_no']);
                        });

                        $level_status.val(item_data['level_status']);
                        $building_select.on('change focus', function(){
                            dialog.statusbar(null);
                        });
                        $level_name.on('change focus', function(){
                            dialog.statusbar(null);
                        })
                    }
                }).show();
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
        }
    };
})();

Floor_list.init('level_list', {
    page_no: Url('?pageNo') || 1,
    page_limit: Url('?pageSize') || 10
});


// 绑定新增事件
$('#level_add').on('click.add', function(){
    var $level_name = null,
        $level_memo = null,
        $level_status = null,
        $building_select = null;

    var add_handler = null;
    function check(){
        return ($.trim($level_name.val()).length!==0) && (($building_select.val()+'')!=='0');
    }

    ArtDialog({
        'skin': 'dialog-form',
        'modal': true,
        'title': '新增楼层信息',
        'content': [
            '<div class="">',
                '<div class="form-group">',
                    '<label for="" class="group__label">*所属楼宇:</label>',
                    '<select class="ui-select group__control J_dialog_building_select">',
                        '<option value="0">请选择楼宇</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*楼层名称:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_level_name" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">楼层描述:</label>',
                    '<textarea class="ui-input group__control J_dialog_level_memo"></textarea>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">楼层状态:</label>',
                    '<select class="ui-select group__control J_dialog_level_status">',
                        '<option value="0">有效</option>',
                        '<option value="1">无效</option>',
                    '</select>',
                '</div>',
            '</div>'
        ].join(''),
        'statusbar': [
            '<div class="dialog-form-tip danger">&nbsp;</div>'
        ].join(''),
        'ok': function(){
            var dialog = this;

            if(add_handler!==null){
                return false;
            }
            if(!check()){
                dialog.statusbar([
                    '<div class="dialog-form-tip danger">',
                        '<i class="fa fa-info-circle"></i>&nbsp;请确认*必填字段',
                    '</div>'
                ].join(''));
                return false;
            }

            dialog.title('正在提交...');
            var update_params = {
                bizType: 'buildingLevel',
                building_no: $building_select.val(),
                level_name: $level_name.val(),
                memo: $level_memo.val(),
                level_status: ($level_status.val() || '0')
            };
            add_handler = $.post('/school/V1/BaseDataInfoService/_addRecord', update_params).done(function(_data, _status, _xhr){
                if(parseInt(_data['code'], 10)===0){
                    dialog.title('新增成功');
                    dialog.statusbar([
                        '<div class="dialog-form-tip success">',
                            '<i class="fa fa-check-circle"></i>&nbsp;修改成功！',
                        '</div>'
                    ].join(''));
                    dialog.button([
                        {
                            value: '关闭',
                            autofocus: true,
                            callback: function(){
                                window.location.reload();
                                return false;
                            }
                        }
                    ]);
                }else{
                    dialog.title('新增楼层信息');
                    dialog.statusbar([
                        '<div class="dialog-form-tip danger">',
                            '<i class="fa fa-info-circle"></i>&nbsp;',
                            _data['msg'],
                        '</div>'
                    ].join(''));
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.title('新增楼层信息');
                dialog.statusbar([
                    '<div class="dialog-form-tip danger">',
                        '<i class="fa fa-info-circle"></i>&nbsp;网络异常，请再试一次',
                    '</div>'
                ].join(''));
            }).always(function(_data, _status, _error) {
                add_handler.abort();
                add_handler = null;
            });
            return false;
        },
        'okValue': '确定',
        onshow: function(){
            var dialog = this;
            $level_name = $(this.node).find('input.J_dialog_level_name').eq(0);
            $level_memo = $(this.node).find('textarea.J_dialog_level_memo').eq(0);
            $level_status = $(this.node).find('select.J_dialog_level_status').eq(0);
            $building_select = $(this.node).find('select.J_dialog_building_select').eq(0);

            SelectDict.get({
                bizType: 'building'
            }, function(_data){
                var options = [];
                $.each(_data, function(_i, _building_option){
                    options.push('<option value="'+ _building_option['building_no'] +'">'+ _building_option['building_name'] +'</option>')
                });
                $building_select.append(options.join(''));
            });

            $building_select.on('change focus', function(){
                dialog.statusbar(null);
            });
            $level_name.on('change focus', function(){
                dialog.statusbar(null);
            });
        }
    }).show();
});

</script>

</body>
</html>
