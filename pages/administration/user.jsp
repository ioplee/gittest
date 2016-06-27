<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>权限管理-用户管理</title>

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
                <span class="breadcrumb-active">用户管理</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;用户列表</span>
                    </div>
                    <div class="panel__body">
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="新增" id="user_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                            </div>
                            <table class="ui-table" id="user_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width: 30px;">序号</th>
                                        <th>用户名称</th>
                                        <th>登录名称</th>
                                        <th style="width: 60px;">类型</th>
                                        <th style="width: 60px;">状态</th>
                                        <th style="width: 150px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="user_list_paging"></div>
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
    SidebarMenu.init('administration', 'user');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js');

var User_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_user_id, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
            if(__item['user_id']==_user_id){
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

        get_resources_handler = $.getJSON('/school/pmc/user/_findPage', {
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="user_item_'+ __item['user_id'] +'">',
                    '<td><input type="checkbox" class="J_select_one" data-user-id="'+ __item['user_id'] +'"></td>',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td>'+ __item['user_name'] +'</td>',
                    '<td>'+ __item['login_name'] +'</td>',
                    '<td>'+ ((parseInt(__item['user_type'], 10)===0) ? '平台' : '其它') +'</td>',
                    '<td>'+ ((parseInt(__item['user_status'], 10)===0) ? '启用' : '禁用') +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="编辑" data-user-id="'+ __item['user_id'] +'"><i class="fa fa-edit"></i>&nbsp;编辑</a>',
                        '<a href="/school/route/administration/user/role?user_id='+ __item['user_id'] +'&name='+ window.encodeURI(__item['user_name']) +'" class="ui-button ui-button-xs" title="角色配置" data-user-id="'+ __item['user_id'] +'"><i class="fa fa-unlock-alt"></i>&nbsp;角色配置</a>',
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
                (!!_data['result'] && _data['result'].length>0) && Paging.init('user_list_paging', {
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
                var item_data = find_by_no($(this).data('user-id'));

                var edit_handler = null;

                var $user_name = null,
                    $login_name = null,
                    $login_pass = null,
                    $mobile = null,
                    $email = null,
                    $memo = null,
                    $user_type = null,
                    $user_status = null;

                function check(){
                    return ($.trim($user_name.val()).length !== 0)
                    && ($.trim($login_name.val()).length !== 0)
                    && ($.trim($login_pass.val()).length !== 0)
                    // && ($.trim($mobile.val()).length !== 0)
                    // && ($.trim($email.val()).length !== 0)
                    // && ($.trim($memo.val()).length !== 0)
                    && ($.trim($user_type.val()).length !== 0)
                    && ($.trim($user_status.val()).length !== 0);
                }

                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '编辑用户',
                    'content': [
                        '<div class="">',
                            '<div class="form-group">',
                                '<label for="" class="group__label">用户ID:</label>',
                                '<span class="group__text">'+ item_data['user_id'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*用户名称:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_user_name" value="'+ item_data['user_name'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*登录名称:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_login_name" value="'+ item_data['login_name'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*登录密码:</label>',
                                '<input type="password" class="ui-input group__control J_dialog_login_pass" value="">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">手机号码:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_mobile" value="'+ (item_data['mobile'] || '') +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">e-mail:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_email" value="'+ (item_data['email'] || '') +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">备注:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_memo" value="'+ (item_data['memo'] || '') +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*用户类型:</label>',
                                '<select class="ui-select group__control J_dialog_user_type">',
                                    '<option value="0">平台</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*用户状态:</label>',
                                '<select class="ui-select group__control J_dialog_user_status">',
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
                            userId: item_data['user_id'],
                            userName: $user_name.val(),
                            loginName: $login_name.val(),
                            loginPass: $login_pass.val(),
                            mobile: $mobile.val(),
                            email: $email.val(),
                            memo: $memo.val(),
                            userStatus: $user_status.val()
                        };
                        edit_handler = $.post('/school/pmc/user/_modify', update_params).done(function(_data, _status, _xhr){
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
                                dialog.title('编辑用户');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip danger">',
                                        '<i class="fa fa-info-circle"></i>&nbsp;',
                                        _data['msg'],
                                    '</div>'
                                ].join(''));
                            }
                        }).fail(function(_xhr, _status, _error) {
                            dialog.title('编辑用户');
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

                        $user_name = $(this.node).find('input.J_dialog_user_name').eq(0);
                        $login_name = $(this.node).find('input.J_dialog_login_name').eq(0);
                        $login_pass = $(this.node).find('input.J_dialog_login_pass').eq(0);
                        $mobile = $(this.node).find('input.J_dialog_mobile').eq(0);
                        $email = $(this.node).find('input.J_dialog_email').eq(0);
                        $memo = $(this.node).find('input.J_dialog_memo').eq(0);
                        $user_type = $(this.node).find('select.J_dialog_user_type').eq(0);
                        $user_status = $(this.node).find('select.J_dialog_user_status').eq(0);

                        $user_type.val(item_data['user_type']);
                        $user_status.val(item_data['user_status']);

                        $(this.node).on('change focus', 'input select textarea', function(){
                            dialog.statusbar(null);
                        });
                    }
                }).show();
            });
        }
    };
})();

User_list.init('user_list', {
    page_no: Url('?pageNo') || 1,
    page_limit: Url('?pageSize') || 10
});

$('#user_add').on('click.add', function(){
    var add_handler = null;

    var $user_name = null,
        $login_name = null,
        $login_pass = null,
        $mobile = null,
        $email = null,
        $memo = null,
        $user_type = null,
        $user_status = null;

    function check(){
        return ($.trim($user_name.val()).length !== 0)
        && ($.trim($login_name.val()).length !== 0)
        && ($.trim($login_pass.val()).length !== 0)
        // && ($.trim($mobile.val()).length !== 0)
        // && ($.trim($email.val()).length !== 0)
        // && ($.trim($memo.val()).length !== 0)
        && ($.trim($user_type.val()).length !== 0)
        && ($.trim($user_status.val()).length !== 0);
    }

    ArtDialog({
        'skin': 'dialog-form',
        'modal': true,
        'title': '新增用户',
        'content': [
            '<div class="">',
                '<div class="form-group">',
                    '<label for="" class="group__label">*用户名称:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_user_name" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*登录名称:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_login_name" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*登录密码:</label>',
                    '<input type="password" class="ui-input group__control J_dialog_login_pass" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">手机号码:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_mobile" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">e-mail:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_email" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">备注:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_memo" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*用户类型:</label>',
                    '<select class="ui-select group__control J_dialog_user_type">',
                        '<option value="0">平台</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*用户状态:</label>',
                    '<select class="ui-select group__control J_dialog_user_status">',
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
                userName: $user_name.val(),
                loginName: $login_name.val(),
                loginPass: $login_pass.val(),
                mobile: $mobile.val(),
                email: $email.val(),
                memo: $memo.val(),
                userStatus: $user_status.val()
            };
            add_handler = $.post('/school/pmc/user/_add', update_params).done(function(_data, _status, _xhr){
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
                    dialog.title('新增用户');
                    dialog.statusbar([
                        '<div class="dialog-form-tip danger">',
                            '<i class="fa fa-info-circle"></i>&nbsp;',
                            _data['msg'],
                        '</div>'
                    ].join(''));
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.title('新增用户');
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

            $user_name = $(this.node).find('input.J_dialog_user_name').eq(0);
            $login_name = $(this.node).find('input.J_dialog_login_name').eq(0);
            $login_pass = $(this.node).find('input.J_dialog_login_pass').eq(0);
            $mobile = $(this.node).find('input.J_dialog_mobile').eq(0);
            $email = $(this.node).find('input.J_dialog_email').eq(0);
            $memo = $(this.node).find('input.J_dialog_memo').eq(0);
            $user_type = $(this.node).find('select.J_dialog_user_type').eq(0);
            $user_status = $(this.node).find('select.J_dialog_user_status').eq(0);

            $(this.node).on('change focus', 'input select textarea', function(){
                dialog.statusbar(null);
            });
        }
    }).show();
});
</script>

</body>
</html>
