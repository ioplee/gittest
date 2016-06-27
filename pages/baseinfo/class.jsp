<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能控制-基础配置-班级</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="./baseinfo.scss" charset="utf-8">
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
                <span class="breadcrumb-active">基础配置</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">班级管理</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;班级列表</span>
                    </div>
                    <div class="panel__body">

                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="新增" id="class_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                            </div>
                            <table class="ui-table" id="class_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width:50px;">序号</th>
                                        <th>班级名称</th>
                                        <th>班主任</th>
                                        <th style="width:130px;">班主任手机</th>
                                        <th style="width:100px;">有效期</th>
                                        <th style="width:60px;">状态</th>
                                        <th style="width:80px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="class_list_paging"></div>
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
    SidebarMenu.init('baseinfo', 'class');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Datepicker = require('datepicker'),
    Paging = require('/components/paging/paging.js');

var Class_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_class_no, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
            if(__item['class_no']==_class_no){
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

        get_resources_handler = $.getJSON('/school/biz/schoolBase/_classPage', {
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="class_item_'+ __item['class_no'] +'">',
                    '<td><input type="checkbox" class="J_select_one" data-class-no="'+ __item['class_no'] +'"></td>',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td class="J_item_name">'+ __item['class_name'] +'</td>',
                    '<td class="J_item_teacher_name">'+ __item['teacher_name'] +'</td>',
                    '<td class="J_item_teacher_mobile">'+ __item['teacher_mobile'] +'</td>',
                    '<td class="J_item_effective_date">'+ __item['effective_date'] +'</td>',
                    '<td class="J_item_status">'+ ((parseInt(__item['class_status'], 10)===0) ? '有效' : '无效') +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="编辑" data-class-no="'+ __item['class_no'] +'"><i class="fa fa-edit"></i>&nbsp;编辑</a>',
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }
    function update_item(_class_no, _data){
        var $item = $('#class_item_'+_class_no);
        if($item.length){
            $item.find('td.J_item_name').eq(0).html(_data['class_name']);
            $item.find('td.J_item_teacher_name').eq(0).html(_data['teacher_name']);
            $item.find('td.J_item_teacher_mobile').eq(0).html(_data['teacher_mobile']);
            $item.find('td.J_item_effective_date').eq(0).html(_data['effective_date']);
            $item.find('td.J_item_status').eq(0).html((parseInt(_data['class_status'], 10)===0) ? '有效' : '无效');

            // update data
            find_by_no(_class_no, function(_index){
                data['result'][_index]['class_name'] = _data['class_name'];
                data['result'][_index]['teacher_name'] = _data['teacher_name'];
                data['result'][_index]['teacher_mobile'] = _data['teacher_mobile'];
                data['result'][_index]['effective_date'] = _data['effective_date'];
                data['result'][_index]['class_status'] = _data['class_status'];
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
                (!!_data['result'] && _data['result'].length>0) && Paging.init('class_list_paging', {
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
                var item_data = find_by_no($(this).data('class-no'));

                var $class_code = null,
                    $class_name = null,
                    $teacher_name = null,
                    $teacher_mobile = null,
                    $teacher_wxsno = null,
                    $teacher_smobile = null,
                    $effective_date = null,
                    $class_status = null;

                var edit_handler = null;
                function check(){
                    return ($.trim($class_code.val()).length !== 0)
                        && ($.trim($class_name.val()).length !== 0)
                        && ($.trim($teacher_name.val()).length !== 0)
                        && ($.trim($teacher_mobile.val()).length !== 0)
                        && ($.trim($effective_date.val()).length !== 0) && /^\d{4}-\d{1,2}-\d{1,2}/.test($.trim($effective_date.val()));
                }

                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '编辑班级信息',
                    'content': [
                        '<div class="">',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*班级序号:</label>',
                                '<span class="group__text">'+ item_data['class_no'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*班级编码:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_class_code" value="'+ item_data['class_code'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*班级名称:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_class_name" value="'+ item_data['class_name'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*班主任:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_teacher_name" value="'+ item_data['teacher_name'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*手机号码:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_teacher_mobile" value="'+ item_data['teacher_mobile'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">微信号:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_teacher_wxsno" value="'+ (item_data['teacher_wxsno'] || '') +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">手机短号:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_teacher_smobile" value="'+ (item_data['teacher_smobile'] || '') +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*有效日期:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_effective_date" value="'+ item_data['effective_date'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">班级状态:</label>',
                                '<select class="ui-select group__control J_dialog_class_status">',
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
                            class_no: item_data['class_no'],
                            class_code: $class_code.val(),
                            class_name: $class_name.val(),
                            teacher_name: $teacher_name.val(),
                            teacher_mobile: $teacher_mobile.val(),
                            teacher_wxsno: $teacher_wxsno.val(),
                            teacher_smobile: $teacher_smobile.val(),
                            effective_date: $effective_date.val(),
                            class_status: $class_status.val()
                        };
                        edit_handler = $.post('/school/biz/schoolBase/_modifyClass', update_params).done(function(_data, _status, _xhr){
                            if(parseInt(_data['code'], 10)===0){
                                update_item(
                                    item_data['class_no'],
                                    $.extend({}, update_params)
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
                                dialog.title('编辑班级信息');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip danger">',
                                        '<i class="fa fa-info-circle"></i>&nbsp;',
                                        _data['msg'],
                                    '</div>'
                                ].join(''));
                            }
                        }).fail(function(_xhr, _status, _error) {
                            dialog.title('编辑班级信息');
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

                        $class_code  = $(this.node).find('input.J_dialog_class_code').eq(0);
                        $class_name  = $(this.node).find('input.J_dialog_class_name').eq(0);
                        $teacher_name  = $(this.node).find('input.J_dialog_teacher_name').eq(0);
                        $teacher_mobile  = $(this.node).find('input.J_dialog_teacher_mobile').eq(0);
                        $teacher_wxsno  = $(this.node).find('input.J_dialog_teacher_wxsno').eq(0);
                        $teacher_smobile  = $(this.node).find('input.J_dialog_teacher_smobile').eq(0);
                        $effective_date  = $(this.node).find('input.J_dialog_effective_date').eq(0);
                        $class_status  = $(this.node).find('select.J_dialog_class_status').eq(0);

                        $effective_date.datepicker({
                            endDate: '0d',
                            format: 'yyyy-mm-dd',
                            autoclose: true,
                            todayHighlight: true
                        });

                        $class_status.val(item_data['class_status']);
                        $class_name.on('change focus', function(){
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
        }
    };
})();

Class_list.init('class_list', {
    page_no: Url('?pageNo') || 1,
    page_limit: Url('?pageSize') || 10
});

// 绑定新增事件
$('#class_add').on('click.add', function(){
    var $class_code = null,
        $class_name = null,
        $teacher_name = null,
        $teacher_mobile = null,
        $teacher_wxsno = null,
        $teacher_smobile = null,
        $effective_date = null,
        $class_status = null;

    var edit_handler = null;
    function check(){
        return ($.trim($class_code.val()).length !== 0)
            && ($.trim($class_name.val()).length !== 0)
            && ($.trim($teacher_name.val()).length !== 0)
            && ($.trim($teacher_mobile.val()).length !== 0)
            && ($.trim($effective_date.val()).length !== 0) && /^\d{4}-\d{1,2}-\d{1,2}/.test($.trim($effective_date.val()));
    }

    ArtDialog({
        'skin': 'dialog-form',
        'modal': true,
        'title': '新增班级',
        'content': [
            '<div class="">',
                '<div class="form-group">',
                    '<label for="" class="group__label">*班级编码:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_class_code" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*班级名称:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_class_name" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*班主任:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_teacher_name" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*手机号码:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_teacher_mobile" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">微信号:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_teacher_wxsno" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">手机短号:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_teacher_smobile" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*有效日期:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_effective_date" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">班级状态:</label>',
                    '<select class="ui-select group__control J_dialog_class_status">',
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
                class_code: $class_code.val(),
                class_name: $class_name.val(),
                teacher_name: $teacher_name.val(),
                teacher_mobile: $teacher_mobile.val(),
                teacher_wxsno: $teacher_wxsno.val(),
                teacher_smobile: $teacher_smobile.val(),
                effective_date: $effective_date.val(),
                class_status: $class_status.val()
            };
            edit_handler = $.post('/school/biz/schoolBase/_addClass', update_params).done(function(_data, _status, _xhr){
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
                    dialog.title('新增班级');
                    dialog.statusbar([
                        '<div class="dialog-form-tip danger">',
                            '<i class="fa fa-info-circle"></i>&nbsp;',
                            _data['msg'],
                        '</div>'
                    ].join(''));
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.title('新增班级');
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

            $class_code  = $(this.node).find('input.J_dialog_class_code').eq(0);
            $class_name  = $(this.node).find('input.J_dialog_class_name').eq(0);
            $teacher_name  = $(this.node).find('input.J_dialog_teacher_name').eq(0);
            $teacher_mobile  = $(this.node).find('input.J_dialog_teacher_mobile').eq(0);
            $teacher_wxsno  = $(this.node).find('input.J_dialog_teacher_wxsno').eq(0);
            $teacher_smobile  = $(this.node).find('input.J_dialog_teacher_smobile').eq(0);
            $effective_date  = $(this.node).find('input.J_dialog_effective_date').eq(0);
            $class_status  = $(this.node).find('select.J_dialog_class_status').eq(0);

            $effective_date.datepicker({
                endDate: '0d',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayHighlight: true
            });

            $class_name.on('change focus', function(){
                dialog.statusbar(null);
            })
        }
    }).show();
});
</script>

</body>
</html>
