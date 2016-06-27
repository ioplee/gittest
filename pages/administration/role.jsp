<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>权限管理-角色管理</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="./administration.scss" charset="utf-8">

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
                <span class="breadcrumb-active">权限管理</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">角色管理</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;角色列表</span>
                    </div>
                    <div class="panel__body">
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="新增" id="role_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                            </div>
                            <table class="ui-table" id="role_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width: 30px;">序号</th>
                                        <th>角色名称</th>
                                        <th style="width: 100px;">角色类型</th>
                                        <th style="width: 60px;">状态</th>
                                        <th style="width: 150px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="role_list_paging"></div>
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
    SidebarMenu.init('administration', 'role');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js');

var Role_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_role_id, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
            if(__item['role_id']==_role_id){
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

        get_resources_handler = $.getJSON('/school/pmc/role/_findPage', {
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
                '<td colspan="6">',
                    '<div class="cell__placeholder">',
                        '<i class="fa fa-spinner fa-spin"></i>&nbsp;数据加载中...',
                    '</div>',
                '</td>'
            ].join(''));
        }
    }
    function render_error(){
        $content.html([
            '<td colspan="6">',
                '<div class="cell__placeholder error">',
                    '<i class="fa fa-info-circle"></i>&nbsp;数据加载失败，<a href="javascript:void(0);" class="placeholder-link J_btn_reload">请再试一次</a>！',
                '</div>',
            '</td>'
        ].join(''));
    }
    function render_data(_result, _offset_base){
        if(_result===undefined || _result.length===0){
            $content.html([
                '<td colspan="6">',
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="role_item_'+ __item['role_id'] +'">',
                    '<td><input type="checkbox" class="J_select_one" data-role-id="'+ __item['role_id'] +'"></td>',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td>'+ __item['role_name'] +'</td>',
                    '<td>'+ ((parseInt(__item['type'], 10)===0) ? '平台' : '其它') +'</td>',
                    '<td>'+ ((parseInt(__item['status'], 10)===0) ? '启用' : '禁用') +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="编辑" data-role-id="'+ __item['role_id'] +'"><i class="fa fa-edit"></i>&nbsp;编辑</a>',
                        '<a href="/school/route/administration/role/prem?role_id='+ __item['role_id'] +'&name='+ window.encodeURI(__item['role_name']) +'" class="ui-button ui-button-xs" title="权限配置" data-role-id="'+ __item['role_id'] +'"><i class="fa fa-unlock-alt"></i>&nbsp;权限配置</a>',
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

            get_resources(page_no, function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('role_list_paging', {
                    pageNo:  _data['pageNo'],
                    totalPages: _data['totalPages'],
                    pageSize: _data['pageSize'],
                    records: _data['records']
                })
            });

            $content.on('click.edit', 'a.J_btn_reload', function(){
                window.location.reload();
            });

            // 绑定单选事件
            $content.on('click.delete', 'input.J_select_one', function(){
                $container.find('input.J_select_all').prop("checked", check_select_all());
            });

            // 绑定全选事件
            $container.on('click.delete', 'input.J_select_all', function(){
                $content.find('input.J_select_one').prop("checked", this.checked);
            });

            // 绑定编辑事件
            $content.on('click.edit', 'a.J_btn_edit', function(){
                var item_data = find_by_no($(this).data('role-id'));

                var edit_handler = null;

                var $role_name = null,
                    $role_type = null,
                    $role_status = null;

                function check(){
                    return ($.trim($role_name.val()).length !== 0) && ($.trim($role_type.val()).length !== 0) && ($.trim($role_status.val()).length !== 0);
                }

                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '编辑角色',
                    'content': [
                        '<div class="">',
                            '<div class="form-group">',
                                '<label for="" class="group__label">角色ID:</label>',
                                '<span class="group__text">'+ item_data['role_id'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*角色名称:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_role_name" value="'+ item_data['role_name'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*角色类型:</label>',
                                '<select class="ui-select group__control J_dialog_role_type">',
                                    '<option value="0">平台</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*角色状态:</label>',
                                '<select class="ui-select group__control J_dialog_role_status">',
                                    '<option value="0">启用</option>',
                                    '<option value="1">禁用</option>',
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
                            roleId: item_data['role_id'],
                            roleName: $role_name.val(),
                            roleType: $role_type.val(),
                            status: $role_status.val()
                        };
                        edit_handler = $.post('/school/pmc/role/_modify', update_params).done(function(_data, _status, _xhr){
                            if(parseInt(_data['code'], 10)===0){
                                dialog.title('编辑成功');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip success">',
                                        '<i class="fa fa-check-circle"></i>&nbsp;编辑成功！',
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
                                dialog.title('编辑角色');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip danger">',
                                        '<i class="fa fa-info-circle"></i>&nbsp;',
                                        _data['msg'],
                                    '</div>'
                                ].join(''));
                            }
                        }).fail(function(_xhr, _status, _error) {
                            dialog.title('编辑角色');
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

                        $role_name = $(this.node).find('input.J_dialog_role_name').eq(0);
                        $role_type = $(this.node).find('select.J_dialog_role_type').eq(0);
                        $role_status = $(this.node).find('select.J_dialog_role_status').eq(0);

                        $role_type.val(item_data['type']);
                        $role_status.val(item_data['status']);

                        $(this.node).on('change focus', 'input select', function(){
                            dialog.statusbar(null);
                        });
                    }
                }).show();
            });
        }
    };
})();

Role_list.init('role_list', {
    page_no: Url('?pageNo') || 1,
    page_limit: Url('?pageSize') || 10
});

$('#role_add').on('click.add', function(){
    var edit_handler = null;

    var $role_name = null,
        $role_type = null,
        $role_status = null;

    function check(){
        return ($.trim($role_name.val()).length !== 0) && ($.trim($role_type.val()).length !== 0) && ($.trim($role_status.val()).length !== 0);
    }

    ArtDialog({
        'skin': 'dialog-form',
        'modal': true,
        'title': '新增角色',
        'content': [
            '<div class="">',
                '<div class="form-group">',
                    '<label for="" class="group__label">*角色名称:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_role_name" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*角色类型:</label>',
                    '<select class="ui-select group__control J_dialog_role_type">',
                        '<option value="0">平台</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*角色状态:</label>',
                    '<select class="ui-select group__control J_dialog_role_status">',
                        '<option value="0">启用</option>',
                        '<option value="1">禁用</option>',
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
                roleName: $role_name.val(),
                roleType: $role_type.val(),
                status: $role_status.val()
            };
            edit_handler = $.post('/school/pmc/role/_add', update_params).done(function(_data, _status, _xhr){
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
                    dialog.title('新增角色');
                    dialog.statusbar([
                        '<div class="dialog-form-tip danger">',
                            '<i class="fa fa-info-circle"></i>&nbsp;',
                            _data['msg'],
                        '</div>'
                    ].join(''));
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.title('新增角色');
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

            $role_name = $(this.node).find('input.J_dialog_role_name').eq(0);
            $role_type = $(this.node).find('select.J_dialog_role_type').eq(0);
            $role_status = $(this.node).find('select.J_dialog_role_status').eq(0);

            $(this.node).on('change focus', 'input select', function(){
                dialog.statusbar(null);
            });
        }
    }).show();
});

</script>

</body>
</html>
