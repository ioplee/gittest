<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能控制-基础配置-房间</title>

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
                <span class="breadcrumb-active">房间</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;房间列表</span>
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
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="新增" id="room_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                            </div>
                            <table class="ui-table" id="room_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width: 30px;">序号</th>
                                        <th>楼宇名称</th>
                                        <th>楼层名称</th>
                                        <th>房间名称</th>
                                        <th>熄灯规则</th>
                                        <th>描述</th>
                                        <th style="width: 60px;">状态</th>
                                        <th style="width: 80px;">操作</th>
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
    SidebarMenu.init('baseinfo', 'room');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js'),
    SelectDict = require('/components/select-option/service.js'),
    RulesDict = require('/components/select-option/rules.js');

var SEARCH_BUILDING_NO = Url('?building_no') || null,
    SEARCH_BUILDING_LEVEL_NO = Url('?level_no') || null;

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
            bizType: 'room',
            pageNo: page_next,
            pageSize: page_limit
        };
        if(_building_no!==null){
            resource_params['building_no'] = _building_no
        }
        if(_building_level_no!==null){
            resource_params['buildingLevel_no'] = _building_level_no
        }

        get_resources_handler = $.getJSON('/school/V1/BaseDataInfoService/_findPage', resource_params).done(function(_data, _status, _xhr){
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="room_item_'+ __item['room_no'] +'">',
                    '<td><input type="checkbox" class="J_select_one" data-building-no="'+ __item['room_no'] +'"></td>',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td class="J_item_building_name">'+ __item['building_name'] +'</td>',
                    '<td class="J_item_level_name">'+ __item['level_name'] +'</td>',
                    '<td class="J_item_name">'+ __item['room_name'] +'</td>',
                    '<td class="J_item_rule_name">'+ (__item['rule_name'] || '--') +'</td>',
                    '<td class="J_item_memo">'+ (__item['room_memo'] || '&nbsp;') +'</td>',
                    '<td class="J_item_status">'+ ((parseInt(__item['room_status'], 10)===0) ? '有效' : '无效') +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="编辑" data-building-no="'+ __item['room_no'] +'"><i class="fa fa-edit"></i>&nbsp;编辑</a>',
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }
    function update_item(_room_no, _data){
        var $item = $('#room_item_'+_room_no);

        if($item.length){
            $item.find('td.J_item_name').eq(0).html(_data['room_name']);
            $item.find('td.J_item_memo').eq(0).html(_data['room_memo']);
            $item.find('td.J_item_status').eq(0).html((parseInt(_data['room_status'], 10)===0) ? '有效' : '无效');
            $item.find('td.J_item_building_name').eq(0).html(_data['building_name']);
            $item.find('td.J_item_level_name').eq(0).html(_data['level_name']);
            $item.find('td.J_item_rule_name').eq(0).html(_data['rule_name']);

            // update data
            find_by_no(_room_no, function(_index){
                data['result'][_index]['room_name'] = _data['room_name'];
                data['result'][_index]['room_memo'] = _data['room_memo'];
                data['result'][_index]['room_status'] = _data['room_status'];
                data['result'][_index]['building_name'] = _data['building_name'];
                data['result'][_index]['building_no'] = _data['building_no'];
                data['result'][_index]['level_name'] = _data['level_name'];
                data['result'][_index]['level_no'] = _data['level_no'];
                data['result'][_index]['rule_id'] = _data['ruleId'];
                data['result'][_index]['rule_name'] = _data['rule_name'] || null;
            })
        }
    }
    function delete_item(_room_no){
        var $item = $('#room_item_'+_room_no);
        if($item.length){
            $item.addClass('table__tr_deleted');

            // update data
            find_by_no(_room_no, function(_index){
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

            get_resources(page_no, _params['building_no'], _params['building_level_no'], function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('room_list_paging', {
                    pageNo:  _data['pageNo'],
                    totalPages: _data['totalPages'],
                    pageSize: _data['pageSize'],
                    records: _data['records']
                })
            });

            // 绑定编辑事件
            $content.on('click.edit', 'a.J_btn_edit', function(){
                var item_data = find_by_no($(this).data('building-no'));

                var $room_name = null,
                    $room_memo = null,
                    $room_status = null,
                    $building_select = null,
                    $level_select = null,
                    $rule_select = null;

                var edit_handler = null;
                function check(){
                    return ($.trim($room_name.val()).length!==0) && (!!$building_select.val() && ($building_select.val()+'')!=='0') && (!!$level_select.val() && ($level_select.val()+'')!=='0');
                }

                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '编辑房间信息',
                    'content': [
                        '<div class="">',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*房间编号:</label>',
                                '<span class="group__text">'+ item_data['room_no'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*所属楼宇:</label>',
                                '<select class="ui-select group__control J_dialog_building_select">',
                                    '<option value="0">请选择楼宇</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*所属楼层:</label>',
                                '<select class="ui-select group__control J_dialog_level_select">',
                                    '<option value="0">请选择楼层</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*房间名称:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_room_name" value="'+ item_data['room_name'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">房间描述:</label>',
                                '<textarea class="ui-input group__control J_dialog_room_memo">'+ (item_data['room_memo']||'&nbsp;') +'</textarea>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">熄灯规则:</label>',
                                '<select class="ui-select group__control J_dialog_rule">',
                                    '<option value="0">无</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">房间状态:</label>',
                                '<select class="ui-select group__control J_dialog_room_status">',
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
                            bizType: 'room',
                            room_no: item_data['room_no'],
                            room_name: $room_name.val(),
                            room_memo: $room_memo.val(),
                            room_status: $room_status.val(),
                            buildinglevel_no: $level_select.val(),
                            ruleId: $rule_select.val()
                        };

                        edit_handler = $.post('/school/V1/BaseDataInfoService/_modifyRecord', update_params).done(function(_data, _status, _xhr){
                            if(parseInt(_data['code'], 10)===0){
                                update_item(
                                    item_data['room_no'],
                                    $.extend({}, update_params,
                                        {
                                            building_no: $building_select.val(),
                                            building_name: $building_select.children('option[value=\''+ $building_select.val() +'\']').text(),
                                            level_no: $level_select.val(),
                                            level_name: $level_select.children('option[value=\''+ $level_select.val() +'\']').text(),
                                            rule_name: RulesDict.get_name_by_value({
                                                    ruleAliase: 'closeLights',
                                                    value: update_params['ruleId'],
                                                    valAliase: 'rule_id',
                                                    keyAliase: 'rule_name'
                                                })
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
                                dialog.title('编辑房间信息');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip danger">',
                                        '<i class="fa fa-info-circle"></i>&nbsp;',
                                        _data['msg'],
                                    '</div>'
                                ].join(''));
                            }
                        }).fail(function(_xhr, _status, _error) {
                            dialog.title('编辑房间信息');
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
                        $room_name = $(this.node).find('input.J_dialog_room_name').eq(0);
                        $room_memo = $(this.node).find('textarea.J_dialog_room_memo').eq(0);
                        $room_status = $(this.node).find('select.J_dialog_room_status').eq(0);
                        $building_select = $(this.node).find('select.J_dialog_building_select').eq(0);
                        $level_select = $(this.node).find('select.J_dialog_level_select').eq(0);
                        $rule_select = $(this.node).find('select.J_dialog_rule').eq(0);

                        SelectDict.get({
                            bizType: 'building'
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _building_option){
                                options.push('<option value="'+ _building_option['building_no'] +'">'+ _building_option['building_name'] +'</option>')
                            });
                            $building_select.append(options.join('')).val(item_data['building_no']);
                        });
                        SelectDict.get({
                            bizType: 'buildingLevel',
                            no: item_data['building_no']
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _level_option){
                                options.push('<option value="'+ _level_option['level_no'] +'">'+ _level_option['level_name'] +'</option>')
                            });
                            $level_select.append(options.join('')).val(item_data['level_no']);
                        });

                        RulesDict.get({
                            'ruleAliase': 'closeLights'
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _rule_option){
                                options.push('<option value="'+ _rule_option['rule_id'] +'">'+ _rule_option['rule_name'] +'</option>')
                            });
                            $rule_select.append(options.join('')).val((item_data['rule_id'] || 0));
                        });

                        $room_status.val(item_data['room_status']);
                        $building_select.on('change focus', function(){
                            dialog.statusbar(null);
                            $level_select.html('<option value="0">请选择楼层</option>').val('0').attr('disabled', 'disabled');
                            SelectDict.get({
                                bizType: 'buildingLevel',
                                no: $(this).val()
                            }, function(_data){
                                var options = [];
                                $.each(_data, function(_i, _level_option){
                                    options.push('<option value="'+ _level_option['level_no'] +'">'+ _level_option['level_name'] +'</option>')
                                });
                                $level_select.append(options.join('')).attr('disabled', null);
                            });
                        });
                        $level_select.on('change focus', function(){
                            dialog.statusbar(null);
                        });
                        $room_name.on('change focus', function(){
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

Room_list.init('room_list', {
    'page_no': Url('?pageNo') || 1,
    'page_limit': Url('?pageSize') || 10,
    'building_no': SEARCH_BUILDING_NO,
    'building_level_no': SEARCH_BUILDING_LEVEL_NO
});


// 绑定新增事件
$('#room_add').on('click.add', function(){
    var $room_name = null,
        $room_memo = null,
        $room_status = null,
        $building_select = null,
        $level_select = null,
        $rule_select = null;

    var edit_handler = null;
    function check(){
        return ($.trim($room_name.val()).length!==0) && (!!$building_select.val() && ($building_select.val()+'')!=='0') && (!!$level_select.val() && ($level_select.val()+'')!=='0');
    }

    ArtDialog({
        'skin': 'dialog-form',
        'modal': true,
        'title': '新增房间信息',
        'content': [
            '<div class="">',
                '<div class="form-group">',
                    '<label for="" class="group__label">*所属楼宇:</label>',
                    '<select class="ui-select group__control J_dialog_building_select">',
                        '<option value="0">请选择楼宇</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*所属楼层:</label>',
                    '<select class="ui-select group__control J_dialog_level_select">',
                        '<option value="0">请选择楼层</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*房间名称:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_room_name" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">房间描述:</label>',
                    '<textarea class="ui-input group__control J_dialog_room_memo"></textarea>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">熄灯规则:</label>',
                    '<select class="ui-select group__control J_dialog_rule">',
                        '<option value="0">无</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">房间状态:</label>',
                    '<select class="ui-select group__control J_dialog_room_status">',
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
                bizType: 'room',
                room_name: $room_name.val(),
                room_memo: $room_memo.val(),
                room_status: $room_status.val(),
                buildinglevel_no: $level_select.val(),
                ruleId: $rule_select.val()
            };
            edit_handler = $.post('/school/V1/BaseDataInfoService/_addRecord', update_params).done(function(_data, _status, _xhr){
                if(parseInt(_data['code'], 10)===0){
                    dialog.title('新增成功');
                    dialog.statusbar([
                        '<div class="dialog-form-tip success">',
                            '<i class="fa fa-check-circle"></i>&nbsp;新增成功！',
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
                    dialog.title('新增房间信息');
                    dialog.statusbar([
                        '<div class="dialog-form-tip danger">',
                            '<i class="fa fa-info-circle"></i>&nbsp;',
                            _data['msg'],
                        '</div>'
                    ].join(''));
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.title('新增房间信息');
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
            $room_name = $(this.node).find('input.J_dialog_room_name').eq(0);
            $room_memo = $(this.node).find('textarea.J_dialog_room_memo').eq(0);
            $room_status = $(this.node).find('select.J_dialog_room_status').eq(0);
            $building_select = $(this.node).find('select.J_dialog_building_select').eq(0);
            $level_select = $(this.node).find('select.J_dialog_level_select').eq(0);
            $rule_select = $(this.node).find('select.J_dialog_rule').eq(0);

            SelectDict.get({
                bizType: 'building'
            }, function(_data){
                var options = [];
                $.each(_data, function(_i, _building_option){
                    options.push('<option value="'+ _building_option['building_no'] +'">'+ _building_option['building_name'] +'</option>')
                });
                $building_select.append(options.join(''));
            });

            RulesDict.get({
                'ruleAliase': 'closeLights'
            }, function(_data){
                var options = [];
                $.each(_data, function(_i, _rule_option){
                    options.push('<option value="'+ _rule_option['rule_id'] +'">'+ _rule_option['rule_name'] +'</option>')
                });
                $rule_select.append(options.join(''));
            });

            $building_select.on('change focus', function(){
                dialog.statusbar(null);
                $level_select.html('<option value="0">请选择楼层</option>').val('0').attr('disabled', 'disabled');
                SelectDict.get({
                    bizType: 'buildingLevel',
                    no: $(this).val()
                }, function(_data){
                    var options = [];
                    $.each(_data, function(_i, _level_option){
                        options.push('<option value="'+ _level_option['level_no'] +'">'+ _level_option['level_name'] +'</option>')
                    });
                    $level_select.append(options.join('')).attr('disabled', null);
                });
            });
            $level_select.on('change focus', function(){
                dialog.statusbar(null);
            });
            $room_name.on('change focus', function(){
                dialog.statusbar(null);
            })
        }
    }).show();
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
