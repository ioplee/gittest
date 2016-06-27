<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能控制-基础配置-学生</title>

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
                <span class="breadcrumb-active">学生</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;学生列表</span>
                    </div>
                    <div class="panel__body">
                        <div class="panel-toolbar">
                            <div class="ui-search">
                                <label for="" class="search-label">快速检索：</label>
                                <div class="search__item">
                                    <select name="" id="search_select_class" class="ui-form-select">
                                        <option value="0">请选择班级</option>
                                    </select>
                                </div>
                                <input type="text" class="ui-input search__item_first" value="" placeholder="学生姓名" id="search_student_name">
                                <input type="text" class="ui-input search__item_first" value="" placeholder="学籍号" id="search_student_code">
                                <a href="javascript:void(0);" class="ui-button ui-button-sm search__item_last" id="search_submit"><i class="fa fa-search"></i></a>
                            </div>
                        </div>
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="新增" id="student_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                            </div>
                            <table class="ui-table" id="student_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width: 30px;">序号</th>
                                        <th>校内号</th>
                                        <th>姓名</th>
                                        <th>班级</th>
                                        <th>寝室</th>
                                        <th style="width: 60px;">状态</th>
                                        <th style="width: 80px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="student_list_paging"></div>
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
    SidebarMenu.init('baseinfo', 'student');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js'),
    ClassDict = require('/components/select-option/class.js');

var SEARCH_CLASS_NO = Url('?class_no') || 0,
    SEARCH_STUDENT_NAME = Url('?student_name') || null,
    SEARCH_STUDENT_CODE = Url('?student_code') || null;
if(SEARCH_STUDENT_NAME!==null){
    SEARCH_STUDENT_NAME = decodeURI(SEARCH_STUDENT_NAME);
}

var Student_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_student_no, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
            if(__item['student_no']==_student_no){
                item = __item;
                $.isFunction(_callback) && _callback(__index);
                return false;
            }
        });

        return item;
    }

    var get_resources_handler = null;
    function get_resources(_page_next, _class_no, _student_name, _student_code, _success_callback){
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
        if(_class_no!==null && _class_no!==0){
            resource_params['class_no'] = _class_no;
        }
        if(_student_name!==null){
            resource_params['student_name'] = _student_name;
        }
        if(_student_code!==null){
            resource_params['student_code'] = _student_code;
        }

        get_resources_handler = $.getJSON('/school/biz/schoolBase/_studentPage', resource_params).done(function(_data, _status, _xhr){
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="student_item_'+ __item['student_no'] +'">',
                    '<td><input type="checkbox" class="J_select_one" data-student-no="'+ __item['student_no'] +'"></td>',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td class="J_item_code">'+ __item['student_code'] +'</td>',
                    '<td class="J_item_name">'+ __item['student_name'] +'</td>',
                    '<td class="J_item_class">'+ __item['class_name'] +'</td>',
                    '<td class="J_item_room">'+ __item['roomName'] +'</td>',
                    '<td class="J_item_status">'+ ((parseInt(__item['status'], 10)===0) ? '有效' : '无效') +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="编辑" data-student-no="'+ __item['student_no'] +'"><i class="fa fa-edit"></i>&nbsp;编辑</a>',
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }
    function update_item(_student_no, _data){
        var $item = $('#student_item_'+_student_no);
        if($item.length){
            $item.find('td.J_item_code').eq(0).html(_data['student_code']);
            $item.find('td.J_item_name').eq(0).html(_data['student_name']);
            $item.find('td.J_item_class').eq(0).html(_data['class_name']);
            $item.find('td.J_item_status').eq(0).html((parseInt(_data['status'], 10)===0) ? '有效' : '无效');

            // update data
            find_by_no(_student_no, function(_index){
                data['result'][_index]['student_code'] = _data['student_code'];
                data['result'][_index]['student_name'] = _data['student_name'];
                data['result'][_index]['class_name'] = _data['class_name'];
                data['result'][_index]['class_no'] = _data['class_no'];
                data['result'][_index]['status'] = _data['status'];
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

            get_resources(page_no, _params['class_no'], _params['student_name'], _params['student_code'], function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('student_list_paging', {
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
                var item_data = find_by_no($(this).data('student-no'));

                var $student_code = null,
                    $student_name = null,
                    $class_select = null,
                    $parent_name = null,
                    $parent_mobile = null,
                    $parent_wxsno = null,
                    $student_status = null;

                var edit_handler = null;
                function check(){
                    return ($.trim($student_code.val()).length !== 0)
                        && ($.trim($student_name.val()).length !== 0)
                        && ($class_select.val() !== 0);
                }

                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '编辑学生信息',
                    'content': [
                        '<div class="">',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*学生编码:</label>',
                                '<span class="group__text">'+ item_data['student_no'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*校内号:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_student_code" value="'+ item_data['student_code'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*学生姓名:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_student_name" value="'+ item_data['student_name'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*所属班级:</label>',
                                '<select class="ui-select group__control J_dialog_class_select">',
                                    '<option value="0">请选择班级</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">家长姓名:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_parent_name" value="'+ (item_data['parent_name'] || '') +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">家长手机:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_parent_mobile" value="'+ (item_data['parent_mobile'] || '') +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">家长微信:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_parent_wxsno" value="'+ (item_data['parent_wxsno'] || '') +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">学生状态:</label>',
                                '<select class="ui-select group__control J_dialog_student_status">',
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
                            student_no: item_data['student_no'],
                            student_code: $student_code.val(),
                            student_name: $student_name.val(),
                            class_no: $class_select.val(),
                            parent_name: $parent_name.val(),
                            parent_mobile: $parent_mobile.val(),
                            parent_wxsno: $parent_wxsno.val(),
                            status: $student_status.val()
                        };
                        edit_handler = $.post('/school/biz/schoolBase/_modifyStudent', update_params).done(function(_data, _status, _xhr){
                            if(parseInt(_data['code'], 10)===0){
                                update_item(
                                    item_data['student_no'],
                                    $.extend({}, update_params, {
                                        class_name: ClassDict.get_name_by_value({
                                            dictAliase: 'class',
                                            value: update_params['class_no'],
                                            valAliase: 'class_no',
                                            keyAliase: 'class_name'
                                        })
                                    })
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
                                dialog.title('编辑学生信息');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip danger">',
                                        '<i class="fa fa-info-circle"></i>&nbsp;',
                                        _data['msg'],
                                    '</div>'
                                ].join(''));
                            }
                        }).fail(function(_xhr, _status, _error) {
                            dialog.title('编辑学生信息');
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
                        $student_code = $(this.node).find('input.J_dialog_student_code').eq(0);
                        $student_name = $(this.node).find('input.J_dialog_student_name').eq(0);
                        $class_select = $(this.node).find('select.J_dialog_class_select').eq(0);
                        $parent_name = $(this.node).find('input.J_dialog_parent_name').eq(0);
                        $parent_mobile = $(this.node).find('input.J_dialog_parent_mobile').eq(0);
                        $parent_wxsno = $(this.node).find('input.J_dialog_parent_wxsno').eq(0);
                        $student_status = $(this.node).find('select.J_dialog_student_status').eq(0);

                        ClassDict.get({
                            dictAliase: 'class'
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _class_option){
                                options.push('<option value="'+ _class_option['class_no'] +'">'+ _class_option['class_name'] +'</option>')
                            });
                            $class_select.append(options.join('')).val(item_data['class_no']);
                        });

                        $student_status.val(item_data['status']);
                        $student_name.on('change focus', function(){
                            dialog.statusbar(null);
                        })
                    }
                }).show();
            });

            // 绑定单选事件
            $content.on('click.all', 'input.J_select_one', function(){
                $container.find('input.J_select_all').prop("checked", check_select_all());
            });

            // 绑定全选事件
            $container.on('click.all', 'input.J_select_all', function(){
                $content.find('input.J_select_one').prop("checked", this.checked);
            });
        }
    };
})();

Student_list.init('student_list', {
    'page_no': Url('?pageNo') || 1,
    'page_limit': Url('?pageSize') || 10,
    'class_no': SEARCH_CLASS_NO,
    'student_name': SEARCH_STUDENT_NAME,
    'student_code': SEARCH_STUDENT_CODE
});

// 绑定新增事件
$('#student_add').on('click.add', function(){
    var $student_code = null,
        $student_name = null,
        $class_select = null,
        $parent_name = null,
        $parent_mobile = null,
        $parent_wxsno = null,
        $student_status = null;

    var edit_handler = null;
    function check(){
        return ($.trim($student_code.val()).length !== 0)
            && ($.trim($student_name.val()).length !== 0)
            && ($class_select.val() !== 0);
    }

    ArtDialog({
        'skin': 'dialog-form',
        'modal': true,
        'title': '新增学生信息',
        'content': [
            '<div class="">',
                '<div class="form-group">',
                    '<label for="" class="group__label">*校内号:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_student_code" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*学生姓名:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_student_name" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*所属班级:</label>',
                    '<select class="ui-select group__control J_dialog_class_select">',
                        '<option value="0">请选择班级</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">家长姓名:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_parent_name" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">家长手机:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_parent_mobile" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">家长微信:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_parent_wxsno" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">学生状态:</label>',
                    '<select class="ui-select group__control J_dialog_student_status">',
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
                student_code: $student_code.val(),
                student_name: $student_name.val(),
                class_no: $class_select.val(),
                parent_name: $parent_name.val(),
                parent_mobile: $parent_mobile.val(),
                parent_wxsno: $parent_wxsno.val(),
                status: $student_status.val()
            };
            edit_handler = $.post('/school/biz/schoolBase/_addStudent', update_params).done(function(_data, _status, _xhr){
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
                    dialog.title('新增学生信息');
                    dialog.statusbar([
                        '<div class="dialog-form-tip danger">',
                            '<i class="fa fa-info-circle"></i>&nbsp;',
                            _data['msg'],
                        '</div>'
                    ].join(''));
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.title('新增学生信息');
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
            $student_code = $(this.node).find('input.J_dialog_student_code').eq(0);
            $student_name = $(this.node).find('input.J_dialog_student_name').eq(0);
            $class_select = $(this.node).find('select.J_dialog_class_select').eq(0);
            $parent_name = $(this.node).find('input.J_dialog_parent_name').eq(0);
            $parent_mobile = $(this.node).find('input.J_dialog_parent_mobile').eq(0);
            $parent_wxsno = $(this.node).find('input.J_dialog_parent_wxsno').eq(0);
            $student_status = $(this.node).find('select.J_dialog_student_status').eq(0);

            ClassDict.get({
                dictAliase: 'class'
            }, function(_data){
                var options = [];
                $.each(_data, function(_i, _class_option){
                    options.push('<option value="'+ _class_option['class_no'] +'">'+ _class_option['class_name'] +'</option>')
                });
                $class_select.append(options.join(''));
            });

            $student_name.on('change focus', function(){
                dialog.statusbar(null);
            })
        }
    }).show();
});

var $search_select_class = $('#search_select_class'),
    $search_student_name = $('#search_student_name'),
    $search_student_code = $('#search_student_code');
ClassDict.get({
    dictAliase: 'class'
}, function(_data){
    var options = [];
    $.each(_data, function(_i, _class_option){
        options.push('<option value="'+ _class_option['class_no'] +'">'+ _class_option['class_name'] +'</option>')
    });
    $search_select_class.append(options.join('')).val(SEARCH_CLASS_NO);
});
$search_student_name.val(SEARCH_STUDENT_NAME);
$search_student_code.val(SEARCH_STUDENT_CODE);

$('#search_submit').on('click', function(){
    var class_no = parseInt($search_select_class.val(), 10),
        student_name = $.trim($search_student_name.val()),
        student_code = $.trim($search_student_code.val()),
        search_url = Url('path');

    var params = {};
    if(class_no!==0){
        params['class_no'] = class_no;
    }
    if(student_name.length>0){
        params['student_name'] = encodeURI(student_name);
    }
    if(student_code.length>0){
        params['student_code'] = student_code;
    }

    window.location.href = search_url + '?' + $.param(params);
});
</script>

</body>
</html>
