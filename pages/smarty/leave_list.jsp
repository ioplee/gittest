<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能考勤</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="./smarty.scss" charset="utf-8">
    <link rel="stylesheet" href="/assets/vendors/bootstrap/dist/css/bootstrap.css" charset="utf-8">
    <link rel="stylesheet" href="assets/vendors/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css" charset="utf-8">
    <link rel="stylesheet" href="assets/vendors/bootstrap-datepicker/dist/css/bootstrap-datepicker3.css" charset="utf-8">

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
                <span class="breadcrumb-active">请假管理</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;请假记录</span>
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
                                <div class="search__item">
                                    <select name="" id="search_select_room" class="ui-form-select">
                                        <option value="0">请选择房间</option>
                                    </select>
                                </div>
                                <input type="text" class="ui-input search__item" value="" placeholder="校内号" id="search_student_code">
                                <label for="" class="search-label">时间：</label>
                                <span id="search_daterange" class="search__item input-daterange">
                                    <input type="text" class="ui-input search-date" id="search_date_start" placeholder="起始时间" name="start">
                                    至
                                    <input type="text" class="ui-input search-date" id="search_date_end" placeholder="结束时间" name="end">
                                </span>
                                <a href="javascript:void(0);" class="ui-button ui-button-sm search__item_last" id="search_submit"><i class="fa fa-search"></i></a>
                            </div>
                        </div>
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="新增" id="leave_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                            </div>
                            <table class="ui-table" id="leave_list">
                                <thead>
                                    <tr>
                                        <th style="width: 46px;">序号</th>
                                        <th>楼宇</th>
                                        <th>楼层</th>
                                        <th>寝室</th>
                                        <th>校内号</th>
                                        <th>姓名</th>
                                        <th style="width: 96px;">开始时间</th>
                                        <th style="width: 96px;">结束时间</th>
                                        <th>请假原因</th>
                                        <th style="width: 66px;">录入人</th>
                                        <th style="width: 96px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="leave_list_paging"></div>
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
    SidebarMenu.init('smarty', 'leave');
});


var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js'),
    Datepicker = require('datepicker'),
    Datetimepicker = require('datetimepicker'),
    StudentDict = require('/components/select-option/student.js');


var SEARCH_BUILDING_NO = Url('?building_no') || null,
    SEARCH_BUILDING_LEVEL_NO = Url('?level_no') || null,
    SEARCH_ROOM_NO = Url('?room_no') || null,
    SEARCH_STUDENT_CODE = Url('?student_code') || null,
    SEARCH_BEGIN_DATE = Url('?beginDate') || null,
    SEARCH_END_DATE = Url('?endDate') || null;

var Leave_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_leave_no, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
            if(__item['leave_no']==_leave_no){
                item = __item;
                $.isFunction(_callback) && _callback(__index);
                return false;
            }
        });

        return item;
    }

    var get_resources_handler = null;
    function get_resources(_page_next, _building_no, _level_no, _room_no, _student_code, _begin_date, _end_date, _success_callback){
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
        if(_building_no!==null && _building_no!==0){
            resource_params['building_no'] = _building_no;
        }
        if(_level_no!==null && _level_no!==0){
            resource_params['level_no'] = _level_no;
        }
        if(_room_no!==null && _room_no!==0){
            resource_params['room_no'] = _room_no;
        }
        if(_student_code!==null && _student_code!==0){
            resource_params['student_code'] = _student_code;
        }
        if(_begin_date!==null){
            resource_params['beginDate'] = _begin_date;
        }
        if(_end_date!==null){
            resource_params['endDate'] = _end_date;
        }

        get_resources_handler = $.getJSON('/school/biz/AppraisalLeave/_page', resource_params).done(function(_data, _status, _xhr){
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
                '<td colspan="11">',
                    '<div class="cell__placeholder">',
                        '<i class="fa fa-spinner fa-spin"></i>&nbsp;数据加载中...',
                    '</div>',
                '</td>'
            ].join(''));
        }
    }
    function render_error(){
        $content.html([
            '<td colspan="11">',
                '<div class="cell__placeholder error">',
                    '<i class="fa fa-info-circle"></i>&nbsp;数据加载失败，<a href="javascript:void(0);" class="placeholder-link J_btn_reload">请再试一次</a>！',
                '</div>',
            '</td>'
        ].join(''));
    }
    function render_data(_result, _offset_base){
        if(_result===undefined || _result.length===0){
            $content.html([
                '<td colspan="11">',
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="leave_item_'+ __item['leave_no'] +'">',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td class="J_item_building_name">'+ __item['building_name'] +'</td>',
                    '<td class="J_item_level_name">'+ __item['level_name'] +'</td>',
                    '<td class="J_item_room_name">'+ __item['room_name'] +'</td>',
                    '<td class="J_item_student_code">'+ __item['student_code'] +'</td>',
                    '<td class="J_item_student_name">'+ __item['student_name'] +'</td>',
                    '<td class="J_item_begin_date">'+ __item['begin_date'] +'</td>',
                    '<td class="J_item_end_date">'+ __item['end_date'] +'</td>',
                    '<td class="J_item_leave_reason">'+ __item['leave_reason'] +'</td>',
                    '<td class="J_item_ori_type">'+ ((parseInt(__item['ori_type'], 10)===1)?'班主任':(parseInt(__item['ori_type'], 10)===2)?'家长':'宿管员') +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="编辑" data-leave-no="'+ __item['leave_no'] +'"><i class="fa fa-edit"></i>&nbsp;编辑</a>',
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }

    return {
        init: function(_$table_id, _params){
            $container = $('#'+_$table_id);
            $content = $container.children('tbody').eq(0);
            page_no = _params['page_no'];
            page_limit = _params['page_limit'];

            get_resources(page_no, _params['building_no'], _params['level_no'], _params['room_no'], _params['student_code'], _params['begin_date'], _params['end_date'], function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('leave_list_paging', {
                    pageNo:  _data['pageNo'],
                    totalPages: _data['totalPages'],
                    pageSize: _data['pageSize'],
                    records: _data['records']
                })
            });

            $content.on('click.edit', 'a.J_btn_reload', function(){
                window.location.reload();
            });

            // 绑定编辑事件
            $content.on('click.edit', 'a.J_btn_edit', function(){
                var item_data = find_by_no($(this).data('leave-no'));

                var $building_select = null,
                    $level_select = null,
                    $room_select = null,
                    $student_select = null,
                    $leave_date = null,
                    $leave_reason = null,
                    $begin_date = null,
                    $end_date = null,
                    $ori_type = null,
                    $leave_status = null;

                var edit_handler = null;
                function check(){
                    return (!!$building_select.val() && ($building_select.val()+'')!=='0')
                        && (!!$level_select.val() && ($level_select.val()+'')!=='0')
                        && (!!$room_select.val() && ($room_select.val()+'')!=='0')
                        && (!!$student_select.val() && ($student_select.val()+'')!=='0')
                        && ($.trim($leave_date.val()).length !== 0) && /^\d{4}-\d{1,2}-\d{1,2}/.test($.trim($leave_date.val()))
                        && ($.trim($leave_reason.val()).length !== 0)
                        && ($.trim($begin_date.val()).length !== 0) && /^\d{4}-\d{1,2}-\d{1,2}/.test($.trim($begin_date.val()))
                        && ($.trim($end_date.val()).length !== 0) && /^\d{4}-\d{1,2}-\d{1,2}/.test($.trim($end_date.val()))
                        && (!!$ori_type.val() && ($ori_type.val()+'')!=='0');
                }

                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '编辑请假记录',
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
                                '<label for="" class="group__label">*所属房间:</label>',
                                '<select class="ui-select group__control J_dialog_room_select">',
                                    '<option value="0">请选择房间</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*所属学生:</label>',
                                '<select class="ui-select group__control J_dialog_student_select">',
                                    '<option value="0">请选择学生</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*请假时间:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_leave_date" value="">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*请假原因:</label>',
                                '<textarea class="ui-input group__control J_dialog_leave_reason">'+ item_data['leave_reason'] +'</textarea>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*开始时间:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_begin_date" value="">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*结束时间:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_end_date" value="">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*请假人:</label>',
                                '<select class="ui-select group__control J_dialog_ori_type">',
                                    '<option value="0">请选择请假人</option>',
                                    '<option value="1">班主任</option>',
                                    '<option value="2">家长</option>',
                                    '<option value="3">宿管员</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*记录状态:</label>',
                                '<select class="ui-select group__control J_dialog_leave_status">',
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
                            leave_no: item_data['leave_no'],
                            student_no: $student_select.val(),
                            leave_date: $leave_date.val(),
                            leave_reason: $leave_reason.val(),
                            begin_date: $begin_date.val(),
                            end_date: $end_date.val(),
                            ori_type: $ori_type.val(),
                            leave_status: $leave_status.val()
                        };

                        edit_handler = $.post('/school/biz/AppraisalLeave/_modify', update_params).done(function(_data, _status, _xhr){
                            if(parseInt(_data['code'], 10)===0){
                                dialog.title('修改成功');
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
                                dialog.title('编辑请假记录');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip danger">',
                                        '<i class="fa fa-info-circle"></i>&nbsp;',
                                        _data['msg'],
                                    '</div>'
                                ].join(''));
                            }
                        }).fail(function(_xhr, _status, _error) {
                            dialog.title('编辑请假记录');
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
                        $building_select = $(this.node).find('select.J_dialog_building_select').eq(0);
                        $level_select = $(this.node).find('select.J_dialog_level_select').eq(0);
                        $room_select = $(this.node).find('select.J_dialog_room_select').eq(0);
                        $student_select = $(this.node).find('select.J_dialog_student_select').eq(0);
                        $leave_date = $(this.node).find('input.J_dialog_leave_date').eq(0);
                        $leave_reason = $(this.node).find('textarea.J_dialog_leave_reason').eq(0);
                        $begin_date = $(this.node).find('input.J_dialog_begin_date').eq(0);
                        $end_date = $(this.node).find('input.J_dialog_end_date').eq(0);
                        $ori_type = $(this.node).find('select.J_dialog_ori_type').eq(0);
                        $leave_status = $(this.node).find('select.J_dialog_leave_status').eq(0);

                        StudentDict.get({
                            bizType: 'building'
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _building_option){
                                options.push('<option value="'+ _building_option['building_no'] +'">'+ _building_option['building_name'] +'</option>')
                            });
                            $building_select.append(options.join('')).val(item_data['building_no']);
                        });
                        StudentDict.get({
                            bizType: 'building_level',
                            no: item_data['building_no']
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _level_option){
                                options.push('<option value="'+ _level_option['level_no'] +'">'+ _level_option['level_name'] +'</option>')
                            });
                            $level_select.append(options.join('')).val(item_data['level_no']);
                        });
                        StudentDict.get({
                            bizType: 'room',
                            no: item_data['level_no']
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _room_option){
                                options.push('<option value="'+ _room_option['room_no'] +'">'+ _room_option['room_name'] +'</option>')
                            });
                            $room_select.append(options.join('')).val(item_data['room_no']);
                        });
                        StudentDict.get({
                            bizType: 'student',
                            no: item_data['room_no']
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _student_option){
                                options.push('<option value="'+ _student_option['student_no'] +'">'+ _student_option['student_name'] +'</option>')
                            });
                            $student_select.append(options.join('')).val(item_data['student_no']);
                        });

                        $building_select.on('change', function(){
                            $level_select.html('<option value="0">请选择楼层</option>').val('0').attr('disabled', 'disabled');
                            $room_select.html('<option value="0">请选择房间</option>').val('0').attr('disabled', 'disabled');
                            $student_select.html('<option value="0">请选择学生</option>').val('0').attr('disabled', 'disabled');
                            StudentDict.get({
                                bizType: 'building_level',
                                no: $(this).val()
                            }, function(_data){
                                var options = [];
                                $.each(_data, function(_i, _level_option){
                                    options.push('<option value="'+ _level_option['level_no'] +'">'+ _level_option['level_name'] +'</option>')
                                });
                                $level_select.append(options.join('')).attr('disabled', null);
                            });
                        });
                        $level_select.on('change', function(){
                            $room_select.html('<option value="0">请选择房间</option>').val('0').attr('disabled', 'disabled');
                            $student_select.html('<option value="0">请选择学生</option>').val('0').attr('disabled', 'disabled');
                            StudentDict.get({
                                bizType: 'room',
                                no: $(this).val()
                            }, function(_data){
                                var options = [];
                                $.each(_data, function(_i, _room_option){
                                    options.push('<option value="'+ _room_option['room_no'] +'">'+ _room_option['room_name'] +'</option>')
                                });
                                $room_select.append(options.join('')).attr('disabled', null);
                            });
                        });
                        $room_select.on('change', function(){
                            $student_select.html('<option value="0">请选择学生</option>').val('0').attr('disabled', 'disabled');
                            StudentDict.get({
                                bizType: 'student',
                                no: $(this).val()
                            }, function(_data){
                                var options = [];
                                $.each(_data, function(_i, _student_option){
                                    options.push('<option value="'+ _student_option['student_no'] +'">'+ _student_option['student_name'] +'</option>')
                                });
                                $student_select.append(options.join('')).attr('disabled', null);
                            });
                        });

                        $leave_date.datepicker({
                            endDate: '0d',
                            format: 'yyyy-mm-dd',
                            autoclose: true,
                            todayHighlight: true
                        }).val(item_data['leave_date'].match(/^\d{4}-\d{1,2}-\d{1,2}/)[0]);

                        $begin_date.datetimepicker({
                            format: 'yyyy-mm-dd hh:ii',
                            autoclose: true,
                            todayHighlight: true
                        }).val(item_data['begin_date']);
                        $end_date.datetimepicker({
                            format: 'yyyy-mm-dd hh:ii',
                            autoclose: true,
                            todayHighlight: true
                        }).val(item_data['end_date']);

                        $ori_type.val(item_data['ori_type']);

                        $leave_status.val(item_data['leave_status']);

                        $(dialog.node).on('change focus', 'input select', function(){
                            dialog.statusbar(null);
                        })
                    }
                }).show();
            });
        }
    };
})();

Leave_list.init('leave_list', {
    'page_no': Url('?pageNo') || 1,
    'page_limit': Url('?pageSize') || 10,
    'building_no': SEARCH_BUILDING_NO,
    'level_no': SEARCH_BUILDING_LEVEL_NO,
    'room_no': SEARCH_ROOM_NO,
    'student_code': SEARCH_STUDENT_CODE,
    'begin_date': SEARCH_BEGIN_DATE,
    'end_date': SEARCH_END_DATE
});

$('#leave_add').on('click.add', function(){
    var $building_select = null,
        $level_select = null,
        $room_select = null,
        $student_select = null,
        $leave_date = null,
        $leave_reason = null,
        $begin_date = null,
        $end_date = null,
        $ori_type = null;

    var edit_handler = null;
    function check(){
        return (!!$building_select.val() && ($building_select.val()+'')!=='0')
            && (!!$level_select.val() && ($level_select.val()+'')!=='0')
            && (!!$room_select.val() && ($room_select.val()+'')!=='0')
            && (!!$student_select.val() && ($student_select.val()+'')!=='0')
            && ($.trim($leave_date.val()).length !== 0) && /^\d{4}-\d{1,2}-\d{1,2}/.test($.trim($leave_date.val()))
            && ($.trim($leave_reason.val()).length !== 0)
            && ($.trim($begin_date.val()).length !== 0) && /^\d{4}-\d{1,2}-\d{1,2}/.test($.trim($begin_date.val()))
            && ($.trim($end_date.val()).length !== 0) && /^\d{4}-\d{1,2}-\d{1,2}/.test($.trim($end_date.val()))
            && (!!$ori_type.val() && ($ori_type.val()+'')!=='0');
    }

    ArtDialog({
        'skin': 'dialog-form',
        'modal': true,
        'title': '新增请假记录',
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
                    '<label for="" class="group__label">*所属房间:</label>',
                    '<select class="ui-select group__control J_dialog_room_select">',
                        '<option value="0">请选择房间</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*所属学生:</label>',
                    '<select class="ui-select group__control J_dialog_student_select">',
                        '<option value="0">请选择学生</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*请假时间:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_leave_date" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*请假原因:</label>',
                    '<textarea class="ui-input group__control J_dialog_leave_reason"></textarea>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*开始时间:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_begin_date" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*结束时间:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_end_date" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*请假人:</label>',
                    '<select class="ui-select group__control J_dialog_ori_type">',
                        '<option value="0">请选择请假人</option>',
                        '<option value="1">班主任</option>',
                        '<option value="2">家长</option>',
                        '<option value="3">宿管员</option>',
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
                student_no: $student_select.val(),
                leave_date: $leave_date.val(),
                leave_reason: $leave_reason.val(),
                begin_date: $begin_date.val(),
                end_date: $end_date.val(),
                ori_type: $ori_type.val(),
                leave_status: 0
            };

            edit_handler = $.post('/school/biz/AppraisalLeave/_add', update_params).done(function(_data, _status, _xhr){
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
                    dialog.title('新增请假记录');
                    dialog.statusbar([
                        '<div class="dialog-form-tip danger">',
                            '<i class="fa fa-info-circle"></i>&nbsp;',
                            _data['msg'],
                        '</div>'
                    ].join(''));
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.title('新增请假记录');
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
            $building_select = $(this.node).find('select.J_dialog_building_select').eq(0);
            $level_select = $(this.node).find('select.J_dialog_level_select').eq(0);
            $room_select = $(this.node).find('select.J_dialog_room_select').eq(0);
            $student_select = $(this.node).find('select.J_dialog_student_select').eq(0);
            $leave_date = $(this.node).find('input.J_dialog_leave_date').eq(0);
            $leave_reason = $(this.node).find('textarea.J_dialog_leave_reason').eq(0);
            $begin_date = $(this.node).find('input.J_dialog_begin_date').eq(0);
            $end_date = $(this.node).find('input.J_dialog_end_date').eq(0);
            $ori_type = $(this.node).find('select.J_dialog_ori_type').eq(0);

            StudentDict.get({
                bizType: 'building'
            }, function(_data){
                var options = [];
                $.each(_data, function(_i, _building_option){
                    options.push('<option value="'+ _building_option['building_no'] +'">'+ _building_option['building_name'] +'</option>')
                });
                $building_select.append(options.join('')).val(0);
            });

            $building_select.on('change', function(){
                $level_select.html('<option value="0">请选择楼层</option>').val('0').attr('disabled', 'disabled');
                $room_select.html('<option value="0">请选择房间</option>').val('0').attr('disabled', 'disabled');
                $student_select.html('<option value="0">请选择学生</option>').val('0').attr('disabled', 'disabled');
                StudentDict.get({
                    bizType: 'building_level',
                    no: $(this).val()
                }, function(_data){
                    var options = [];
                    $.each(_data, function(_i, _level_option){
                        options.push('<option value="'+ _level_option['level_no'] +'">'+ _level_option['level_name'] +'</option>')
                    });
                    $level_select.append(options.join('')).attr('disabled', null);
                });
            });
            $level_select.on('change', function(){
                $room_select.html('<option value="0">请选择房间</option>').val('0').attr('disabled', 'disabled');
                $student_select.html('<option value="0">请选择学生</option>').val('0').attr('disabled', 'disabled');
                StudentDict.get({
                    bizType: 'room',
                    no: $(this).val()
                }, function(_data){
                    var options = [];
                    $.each(_data, function(_i, _room_option){
                        options.push('<option value="'+ _room_option['room_no'] +'">'+ _room_option['room_name'] +'</option>')
                    });
                    $room_select.append(options.join('')).attr('disabled', null);
                });
            });
            $room_select.on('change', function(){
                $student_select.html('<option value="0">请选择学生</option>').val('0').attr('disabled', 'disabled');
                StudentDict.get({
                    bizType: 'student',
                    no: $(this).val()
                }, function(_data){
                    var options = [];
                    $.each(_data, function(_i, _student_option){
                        options.push('<option value="'+ _student_option['student_no'] +'">'+ _student_option['student_name'] +'</option>')
                    });
                    $student_select.append(options.join('')).attr('disabled', null);
                });
            });

            $leave_date.datepicker({
                endDate: '0d',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayHighlight: true
            });

            $begin_date.datetimepicker({
                format: 'yyyy-mm-dd hh:ii',
                autoclose: true,
                todayHighlight: true
            });
            $end_date.datetimepicker({
                format: 'yyyy-mm-dd hh:ii',
                autoclose: true,
                todayHighlight: true
            });

            $(dialog.node).on('change focus', 'input select', function(){
                dialog.statusbar(null);
            })
        }
    }).show();
});

var $search_select_building = $('#search_select_building'),
    $search_select_level = $('#search_select_level'),
    $search_select_room = $('#search_select_room'),
    $search_date_start = $('#search_date_start'),
    $search_date_end = $('#search_date_end'),
    $search_student_code = $('#search_student_code');

$('#search_daterange').datepicker({
    endDate: '0d',
    format: 'yyyy-mm-dd',
    autoclose: true,
    todayHighlight: true
}).on('changeDate', function(){
    // console.log(this.value)
});

StudentDict.get({
    bizType: 'building'
}, function(_data){
    var options = [];
    $.each(_data, function(_i, _building_option){
        options.push('<option value="'+ _building_option['building_no'] +'">'+ _building_option['building_name'] +'</option>')
    });
    $search_select_building.append(options.join(''));

    // init search select
    if(SEARCH_BUILDING_NO!==null){

        $search_select_building.val(SEARCH_BUILDING_NO);

        StudentDict.get({
            bizType: 'building_level',
            no: SEARCH_BUILDING_NO
        }, function(_data){
            var options = ['<option value="0">请选择楼层</option>'];
            $.each(_data, function(_i, _building_level_option){
                options.push('<option value="'+ _building_level_option['level_no'] +'">'+ _building_level_option['level_name'] +'</option>')
            });
            $search_select_level.html(options.join(''));

            // init search select
            if(SEARCH_BUILDING_LEVEL_NO!==null){

                $search_select_level.val(SEARCH_BUILDING_LEVEL_NO);

                StudentDict.get({
                    bizType: 'room',
                    no: SEARCH_BUILDING_LEVEL_NO
                }, function(_data){
                    var options = ['<option value="0">请选择房间</option>'];
                    $.each(_data, function(_i, _room_option){
                        options.push('<option value="'+ _room_option['room_no'] +'">'+ _room_option['room_name'] +'</option>')
                    });
                    $search_select_room.html(options.join('')).val(SEARCH_ROOM_NO || 0);
                });
            }
        });
    }
});

$search_select_building.on('change', function(){
    var building_no = $(this).val(),
        options = ['<option value="0">请选择楼层</option>'];
    if(parseInt(building_no, 10)===0){
        $search_select_level.html(options.join('')).val(0);
    }else{
        StudentDict.get({
            bizType: 'building_level',
            no: building_no
        }, function(_data){
            $.each(_data, function(_i, _building_level_option){
                options.push('<option value="'+ _building_level_option['level_no'] +'">'+ _building_level_option['level_name'] +'</option>')
            });
            $search_select_level.html(options.join('')).val(0);
        });
    }
});

$search_select_level.on('change', function(){
    var building_level_no = $(this).val(),
        options = ['<option value="0">请选择房间</option>'];
    if(parseInt(building_level_no, 10)===0){
        $search_select_room.html(options.join('')).val(0);
    }else{
        StudentDict.get({
            bizType: 'room',
            no: building_level_no
        }, function(_data){
            $.each(_data, function(_i, _room_option){
                options.push('<option value="'+ _room_option['room_no'] +'">'+ _room_option['room_name'] +'</option>')
            });
            $search_select_room.html(options.join('')).val(0);
        });
    }
});

$search_student_code.val(SEARCH_STUDENT_CODE);

$('#search_submit').on('click', function(){
    var building_no = parseInt($search_select_building.val(), 10),
        level_no = parseInt($search_select_level.val(), 10),
        room_no = parseInt($search_select_room.val(), 10),
        student_code = $.trim($search_student_code.val()),
        beginDate = $.trim($search_date_start.val()),
        endDate = $.trim($search_date_end.val());

    var search_url = Url('path');

    var params = {};
    if(building_no!==0){
        params['building_no'] = building_no;
    }
    if(level_no!==0){
        params['level_no'] = level_no;
    }
    if(room_no!==0){
        params['room_no'] = room_no;
    }
    if(student_code.length>0){
        params['student_code'] = student_code;
    }
    if(beginDate.length>0 && /^\d{4}-\d{1,2}-\d{1,2}/.test(beginDate)){
        params['beginDate'] = beginDate.replace(/-/gi, '');
    }
    if(endDate.length>0 && /^\d{4}-\d{1,2}-\d{1,2}/.test(endDate)){
        params['endDate'] = endDate.replace(/-/gi, '');
    }

    window.location.href = search_url + '?' + $.param(params);
});
</script>

</body>
</html>
