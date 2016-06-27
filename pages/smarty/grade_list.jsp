<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能考勤--宿舍评分</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="./smarty.scss" charset="utf-8">
    <link rel="stylesheet" href="/assets/vendors/bootstrap/dist/css/bootstrap.css" charset="utf-8">
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
                <span class="breadcrumb-active">智能考勤</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">宿舍评分</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;宿舍评分列表</span>
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
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="新增" id="record_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                            </div>
                            <table class="ui-table" id="record_list">
                                <thead>
                                    <tr>
                                        <th style="width: 46px;">序号</th>
                                        <th>楼宇</th>
                                        <th>楼层</th>
                                        <th>寝室</th>
                                        <th>校内号</th>
                                        <th>姓名</th>
                                        <th style="width: 96px;">评分时间</th>
                                        <th style="width: 96px;">评分类型</th>
                                        <th style="width: 56px;">评分</th>
                                        <th style="width: 96px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="record_list_paging"></div>
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
    SidebarMenu.init('smarty', 'grade');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js'),
    Datepicker = require('datepicker'),
    StudentDict = require('/components/select-option/student.js'),
    RulesDict = require('/components/select-option/rules.js');


var SEARCH_BUILDING_NO = Url('?building_no') || null,
    SEARCH_BUILDING_LEVEL_NO = Url('?level_no') || null,
    SEARCH_ROOM_NO = Url('?room_no') || null,
    SEARCH_STUDENT_CODE = Url('?student_code') || null,
    SEARCH_BEGIN_DATE = Url('?beginDate') || null,
    SEARCH_END_DATE = Url('?endDate') || null;


var Record_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_record_no, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
            if(__item['record_no']==_record_no){
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

        get_resources_handler = $.getJSON('/school/biz/AppraisalRecord/_recordPage', resource_params).done(function(_data, _status, _xhr){
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
                '<td colspan="10">',
                    '<div class="cell__placeholder">',
                        '<i class="fa fa-spinner fa-spin"></i>&nbsp;数据加载中...',
                    '</div>',
                '</td>'
            ].join(''));
        }
    }
    function render_error(){
        $content.html([
            '<td colspan="10">',
                '<div class="cell__placeholder error">',
                    '<i class="fa fa-info-circle"></i>&nbsp;数据加载失败，<a href="javascript:void(0);" class="placeholder-link J_btn_reload">请再试一次</a>！',
                '</div>',
            '</td>'
        ].join(''));
    }
    function render_data(_result, _offset_base){
        if(_result===undefined || _result.length===0){
            $content.html([
                '<td colspan="10">',
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="record_item_'+ __item['record_no'] +'">',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td class="J_item_building_name">'+ __item['building_name'] +'</td>',
                    '<td class="J_item_level_name">'+ __item['level_name'] +'</td>',
                    '<td class="J_item_room_name">'+ __item['room_name'] +'</td>',
                    '<td class="J_item_student_code">'+ __item['student_code'] +'</td>',
                    '<td class="J_item_student_name">'+ __item['student_name'] +'</td>',
                    '<td class="J_item_record_date">'+ __item['record_date'] +'</td>',
                    '<td class="J_item_record_type">'+ ((parseInt(__item['record_type'], 10)===1)?'个人考评':'寝室考评') +'</td>',
                    '<td class="J_item_rule_value">'+ __item['rule_value'] +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="编辑" data-record-no="'+ __item['record_no'] +'"><i class="fa fa-edit"></i>&nbsp;编辑</a>',
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }
    function update_item(_record_no, _data){
        var $item = $('#record_item_'+_record_no);
        if($item.length){
            $item.find('J_item_building_name').eq(0).html(_data['building_name']);
            $item.find('J_item_level_name').eq(0).html(_data['level_name']);
            $item.find('J_item_room_name').eq(0).html(_data['room_name']);
            $item.find('J_item_student_code').eq(0).html(_data['student_code']);
            $item.find('J_item_student_name').eq(0).html(_data['student_name']);
            $item.find('J_item_record_date').eq(0).html(_data['record_date']);
            $item.find('J_item_record_type').eq(0).html((parseInt(_data['record_type'], 10)===1)?'个人考评':'寝室考评');
            $item.find('J_item_rule_value').eq(0).html(_data['rule_value']);

            // update data
            find_by_no(_record_no, function(_index){
                $.each(_data, function(_key, _val){
                    if(data['result'][_index][_key] !== undefined){
                        data['result'][_index][_key] = _val
                    }
                })
            })
        }
    }

    return {
        init: function(_$table_id, _params){
            $container = $('#'+_$table_id);
            $content = $container.children('tbody').eq(0);
            page_no = _params['page_no'];
            page_limit = _params['page_limit'];

            get_resources(page_no, _params['building_no'], _params['level_no'], _params['room_no'], _params['student_code'], _params['begin_date'], _params['end_date'], function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('record_list_paging', {
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
                var item_data = find_by_no($(this).data('record-no'));

                var $record_status = null;
                // var $building_select = null,
                //     $level_select = null,
                //     $room_select = null,
                //     $student_select = null,
                //     $record_type = null,
                //     $record_rule = null,
                //     $record_status = null,
                //     $record_date = null;

                var edit_handler = null;
                // function check(){
                //     return (!!$building_select.val() && ($building_select.val()+'')!=='0')
                //         && (!!$level_select.val() && ($level_select.val()+'')!=='0')
                //         && (!!$room_select.val() && ($room_select.val()+'')!=='0')
                //         // && ((($record_type.val()+'')==='2') || ((($record_type.val()+'')==='1') && (!!$student_select.val() && ($student_select.val()+'')!=='0')))
                //         && (!!$record_rule.val() && ($record_rule.val()+'')!=='0')
                //         && ($.trim($record_date.val()).length !== 0) && /^\d{4}-\d{1,2}-\d{1,2}/.test($.trim($record_date.val()));
                // }

                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '编辑宿舍评分记录',
                    'content': [
                        '<div class="">',
                            '<div class="form-group">',
                                '<label for="" class="group__label">记录编号:</label>',
                                '<span class="group__text">'+ item_data['record_no'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*所属楼宇:</label>',
                                '<span class="group__text">'+ item_data['building_name'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*所属楼层:</label>',
                                '<span class="group__text">'+ item_data['level_name'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*所属房间:</label>',
                                '<span class="group__text">'+ item_data['room_name'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*所属学生:</label>',
                                '<span class="group__text">'+ item_data['student_name'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*评分范围:</label>',
                                '<span class="group__text">'+ ((parseInt(item_data['record_type'], 10)===1)?'个人考评':'寝室考评') +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*评分规则:</label>',
                                '<span class="group__text">'+ item_data['rule_name'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*评分日期:</label>',
                                '<span class="group__text">'+ item_data['record_date'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*评分状态:</label>',
                                '<select class="ui-select group__control J_dialog_record_status">',
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
                        // if(!check()){
                        //     dialog.statusbar([
                        //         '<div class="dialog-form-tip danger">',
                        //             '<i class="fa fa-info-circle"></i>&nbsp;请确认*必填字段',
                        //         '</div>'
                        //     ].join(''));
                        //     return false;
                        // }

                        dialog.title('正在提交...');
                        var update_params = {
                            record_no: item_data['record_no'],
                            student_no: item_data['student_no'],
                            room_no: item_data['room_no'],
                            record_type: item_data['record_type'],
                            rule_no: item_data['rule_no'],
                            rule_value: item_data['rule_value'],
                            record_date: item_data['record_date'],
                            record_status: $record_status.val()
                        };
                        if(parseInt(item_data['record_type'], 10) === 2){
                            update_params['orderid'] = item_data['orderid']
                        }
                        edit_handler = $.post('/school/biz/AppraisalRecord/_modify', update_params).done(function(_data, _status, _xhr){
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
                                dialog.title('编辑宿舍评分记录');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip danger">',
                                        '<i class="fa fa-info-circle"></i>&nbsp;',
                                        _data['msg'],
                                    '</div>'
                                ].join(''));
                            }
                        }).fail(function(_xhr, _status, _error) {
                            dialog.title('编辑宿舍评分记录');
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
                        // $building_select = $(this.node).find('select.J_dialog_building_select').eq(0);
                        // $level_select = $(this.node).find('select.J_dialog_level_select').eq(0);
                        // $room_select = $(this.node).find('select.J_dialog_room_select').eq(0);
                        // $student_select = $(this.node).find('select.J_dialog_student_select').eq(0);
                        // $record_type = $(this.node).find('select.J_dialog_record_type').eq(0);
                        // $record_rule = $(this.node).find('select.J_dialog_rule_select').eq(0);
                        $record_status = $(this.node).find('select.J_dialog_record_status').eq(0);
                        // $record_date = $(this.node).find('input.J_dialog_record_date').eq(0);

                        // $record_type.attr('disabled', 'disabled');

                        // StudentDict.get({
                        //     bizType: 'building'
                        // }, function(_data){
                        //     var options = [];
                        //     $.each(_data, function(_i, _building_option){
                        //         options.push('<option value="'+ _building_option['building_no'] +'">'+ _building_option['building_name'] +'</option>')
                        //     })
                        //     $building_select.append(options.join('')).val(item_data['building_no']);
                        // });
                        // StudentDict.get({
                        //     bizType: 'building_level',
                        //     no: item_data['building_no']
                        // }, function(_data){
                        //     var options = [];
                        //     $.each(_data, function(_i, _level_option){
                        //         options.push('<option value="'+ _level_option['level_no'] +'">'+ _level_option['level_name'] +'</option>')
                        //     })
                        //     $level_select.append(options.join('')).val(item_data['level_no']);
                        // });
                        // StudentDict.get({
                        //     bizType: 'room',
                        //     no: item_data['level_no']
                        // }, function(_data){
                        //     var options = [];
                        //     $.each(_data, function(_i, _room_option){
                        //         options.push('<option value="'+ _room_option['room_no'] +'">'+ _room_option['room_name'] +'</option>')
                        //     })
                        //     $room_select.append(options.join('')).val(item_data['room_no']);
                        // });
                        // StudentDict.get({
                        //     bizType: 'student',
                        //     no: item_data['room_no']
                        // }, function(_data){
                        //     var options = [];
                        //     $.each(_data, function(_i, _student_option){
                        //         options.push('<option value="'+ _student_option['student_no'] +'">'+ _student_option['student_name'] +'</option>')
                        //     })
                        //     $student_select.append(options.join('')).val(item_data['student_no']);
                        // });

                        // RulesDict.get({
                        //     'ruleAliase': 'appraisalRules'
                        // }, function(_data){
                        //     var options = [],
                        //         rule_no = 0;
                        //     $.each(_data, function(_i, _rule_option){
                        //         options.push('<option value="'+ _rule_option['rule_no'] +'">'+ _rule_option['rule_name'] +'</option>')

                        //         if(~_rule_option['rule_name'].indexOf(item_data['rule_name'])){
                        //             rule_no = _rule_option['rule_no'];
                        //         }
                        //     })
                        //     $record_rule.append(options.join('')).val(rule_no);
                        // });

                        // $building_select.on('change focus', function(){
                        //     $level_select.html('<option value="0">请选择楼层</option>').val('0').attr('disabled', 'disabled');
                        //     $room_select.html('<option value="0">请选择房间</option>').val('0').attr('disabled', 'disabled');
                        //     StudentDict.get({
                        //         bizType: 'building_level',
                        //         no: $(this).val()
                        //     }, function(_data){
                        //         var options = [];
                        //         $.each(_data, function(_i, _level_option){
                        //             options.push('<option value="'+ _level_option['level_no'] +'">'+ _level_option['level_name'] +'</option>')
                        //         })
                        //         $level_select.append(options.join('')).attr('disabled', null);
                        //     });
                        // });
                        // $level_select.on('change focus', function(){
                        //     $room_select.html('<option value="0">请选择房间</option>').val('0').attr('disabled', 'disabled');
                        //     StudentDict.get({
                        //         bizType: 'room',
                        //         no: $(this).val()
                        //     }, function(_data){
                        //         var options = [];
                        //         $.each(_data, function(_i, _room_option){
                        //             options.push('<option value="'+ _room_option['room_no'] +'">'+ _room_option['room_name'] +'</option>')
                        //         })
                        //         $room_select.append(options.join('')).attr('disabled', null);
                        //     });
                        // });
                        // $room_select.on('change focus', function(){
                        //     $student_select.html('<option value="0">全部学生</option>').val('0').attr('disabled', 'disabled');
                        //     StudentDict.get({
                        //         bizType: 'student',
                        //         no: $(this).val()
                        //     }, function(_data){
                        //         var options = [];
                        //         $.each(_data, function(_i, _student_option){
                        //             options.push('<option value="'+ _student_option['student_no'] +'">'+ _student_option['student_name'] +'</option>')
                        //         })
                        //         $student_select.append(options.join('')).attr('disabled', null);
                        //     });
                        // });

                        // $record_date.datepicker({
                        //     endDate: '0d',
                        //     format: 'yyyy-mm-dd',
                        //     autoclose: true,
                        //     todayHighlight: true
                        // }).val(item_data['record_date']);

                        $record_status.val(item_data['record_status']);

                        $(dialog.node).on('change focus', 'input select', function(){
                            dialog.statusbar(null);
                        })
                    }
                }).show();
            });
        }
    };
})();

Record_list.init('record_list', {
    'page_no': Url('?pageNo') || 1,
    'page_limit': Url('?pageSize') || 10,
    'building_no': SEARCH_BUILDING_NO,
    'level_no': SEARCH_BUILDING_LEVEL_NO,
    'room_no': SEARCH_ROOM_NO,
    'student_code': SEARCH_STUDENT_CODE,
    'begin_date': SEARCH_BEGIN_DATE,
    'end_date': SEARCH_END_DATE
});

// 绑定新增事件
$('#record_add').on('click.add', function(){
    var $building_select = null,
        $level_select = null,
        $room_select = null,
        $student_select = null,
        $record_type = null,
        $record_rule = null,
        $record_status = null,
        $record_date = null;

    var edit_handler = null;
    function check(){
        return (!!$building_select.val() && ($building_select.val()+'')!=='0')
            && (!!$level_select.val() && ($level_select.val()+'')!=='0')
            && (!!$room_select.val() && ($room_select.val()+'')!=='0')
            // && ((($record_type.val()+'')==='2') || ((($record_type.val()+'')==='1') && (!!$student_select.val() && ($student_select.val()+'')!=='0')))
            && (!!$record_rule.val() && ($record_rule.val()+'')!=='0')
            && ($.trim($record_date.val()).length !== 0) && /^\d{4}-\d{1,2}-\d{1,2}/.test($.trim($record_date.val()));
    }

    ArtDialog({
        'skin': 'dialog-form',
        'modal': true,
        'title': '新增宿舍评分记录',
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
                        '<option value="0">全部学生</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*评分范围:</label>',
                    '<select class="ui-select group__control J_dialog_record_type">',
                        '<option value="0">寝室扣分</option>',
                        '<option value="1">个人扣分</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*评分规则:</label>',
                    '<select class="ui-select group__control J_dialog_rule_select">',
                        '<option value="0">请选择评分规则</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*评分日期:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_record_date" value="">',
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
                room_no: $room_select.val(),
                record_type: $record_type.val(),
                rule_no: $record_rule.val(),
                record_date: $record_date.val()
            };

            edit_handler = $.post('/school/biz/AppraisalRecord/_add', update_params).done(function(_data, _status, _xhr){
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
                    dialog.title('新增宿舍评分记录');
                    dialog.statusbar([
                        '<div class="dialog-form-tip danger">',
                            '<i class="fa fa-info-circle"></i>&nbsp;',
                            _data['msg'],
                        '</div>'
                    ].join(''));
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.title('新增宿舍评分记录');
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
            $record_type = $(this.node).find('select.J_dialog_record_type').eq(0);
            $record_rule = $(this.node).find('select.J_dialog_rule_select').eq(0);
            $record_date = $(this.node).find('input.J_dialog_record_date').eq(0);

            StudentDict.get({
                bizType: 'building'
            }, function(_data){
                var options = [];
                $.each(_data, function(_i, _building_option){
                    options.push('<option value="'+ _building_option['building_no'] +'">'+ _building_option['building_name'] +'</option>')
                });
                $building_select.append(options.join('')).val(0);
            });

            RulesDict.get({
                'ruleAliase': 'appraisalRules'
            }, function(_data){
                var options = [];
                $.each(_data, function(_i, _rule_option){
                    options.push('<option value="'+ _rule_option['rule_no'] +'">'+ _rule_option['rule_name'] +'</option>')
                });
                $record_rule.append(options.join('')).val(0);
            });

            $building_select.on('change focus', function(){
                $level_select.html('<option value="0">请选择楼层</option>').val('0').attr('disabled', 'disabled');
                $room_select.html('<option value="0">请选择房间</option>').val('0').attr('disabled', 'disabled');
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
            $level_select.on('change focus', function(){
                $room_select.html('<option value="0">请选择房间</option>').val('0').attr('disabled', 'disabled');
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
            $room_select.on('change focus', function(){
                $student_select.html('<option value="0">全部学生</option>').val('0').attr('disabled', 'disabled');
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

            $record_date.datepicker({
                endDate: '0d',
                format: 'yyyy-mm-dd',
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
