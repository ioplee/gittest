<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>权限管理-角色管理-权限管理</title>

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
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">权限管理</span>
            </div>

            <div class="body-content__wrapper">
                <form action="#" class="ui-panel ui-form prem-from" id="role_form">
                    <div class="panel__header">
                        <a href="/school/route/administration/role" class="ui-button ui-button-sm fn-right" title="返回"><i class="fa fa-undo"></i>&nbsp;返回</a>
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;角色信息</span>
                    </div>
                    <div class="panel__body">
                        <div class="form-group">
                            <label for="" class="group__label">角色名称：</label>
                            <span class="group__text" id="role_name"></span>
                        </div>
                        <div class="form-group" style="width:70%">
                            <label for="" class="group__label">角色权限：</label>
                            <div class="group__control" id="prem_list_container"><i class="fa fa-spinner fa-spin"></i>&nbsp;数据加载中...</div>
                        </div>
                    </div>
                    <!--// .panel__body -->
                    <div class="panel__footer">
                        <input type="submit" value="&nbsp;确&nbsp;认&nbsp;" class="ui-button ui-button-sm ui-button-primary">
                        <input type="button" value="&nbsp;重&nbsp;置&nbsp;" class="ui-button ui-button-sm" id="prem_form_reset">&nbsp;&nbsp;<span style="color:#999">(*重置后需要“确认”才能生效)</span>
                    </div>
                </form>
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
    Url = require('url');

var ROLE_NAME = Url('?name') || null;
if(ROLE_NAME!==null){
    $('#role_name').html(window.decodeURI(ROLE_NAME));
}

var ROLE_ID = Url('?id') || null;

var PremList = (function(){
    var $prem_list_container = $('#prem_list_container');

    var checked_prem_list = {},
        prem_list = [],
        role_prem_list = [],
        get_resources_handler = null,
        get_role_prem_handler = null;

    var checked_prem_id_list_reset = [];

    function render_error(){
        $prem_list_container.html([
            '<div class="error">',
                '<i class="fa fa-info-circle"></i>&nbsp;数据加载失败，<a href="javascript:void(0);" class="J_btn_reload">请再试一次</a>！',
            '</div>'
        ].join(''));
    }
    function render_loading(){
        $prem_list_container.html('<i class="fa fa-spinner fa-spin"></i>&nbsp;数据加载中...');
    }

    function get_role_prem_list(_role_id, _success){
        if(get_role_prem_handler!==null){
            return false;
        }

        render_loading();

        get_role_prem_handler = $.getJSON('/school/pmc/rela/_findRPPage', {
            'roleId': _role_id
        }).done(function(_data, _status, _xhr){
                if(parseInt(_data['code'], 10)===0){
                    role_prem_list = _data['result'];

                    var checked_prem_id_list = [];

                    if(_data['result']!==undefined){
                        $.each(_data['result'], function(_prem_index, _prem){
                            checked_prem_id_list.push(_prem['prem_id']);
                        });
                    }

                    checked_prem_id_list_reset = checked_prem_id_list.concat([]);

                    $.isFunction(_success) && _success(checked_prem_id_list);
                }else{
                    render_error();
                }
            }).fail(function(_xhr, _status, _error) {
                render_error();
            }).always(function(_data, _status, _error) {
                get_role_prem_handler.abort();
                get_role_prem_handler = null;
            });
    }

    function get_prem_list(_checked_prem_list){
        if(get_resources_handler!==null){
            return false;
        }

        render_loading();

        get_resources_handler = $.getJSON('/school/pmc/perm/_findPage', {
            // 暂定为100，即默认加载全部
            'pageSize': 100
        }).done(function(_data, _status, _xhr){
                if(parseInt(_data['code'], 10)===0){
                    prem_list = _data['result'];

                    var prem_tpl = [];

                    $.each(prem_list, function(_index, _prem){
                        prem_tpl.push('<label for="prem_item_'+ _prem['perm_id'] +'" class="group__checkbox">');

                        if(_checked_prem_list.length){
                            var is_checked = false;

                            $.each(_checked_prem_list, function(_init_index, _init_prem){
                                if(_init_prem == _prem['perm_id']){
                                    is_checked = true;

                                    _checked_prem_list.splice(_init_index, 1);
                                    prem_tpl.push('<input type="checkbox" id="prem_item_'+ _prem['perm_id'] +'" class="checkbox__ipt J_prem_item" checked />');

                                    checked_prem_list[_prem['perm_id']] = true;

                                }
                            });

                            if(is_checked===false){
                                prem_tpl.push('<input type="checkbox" id="prem_item_'+ _prem['perm_id'] +'" class="checkbox__ipt J_prem_item" />');

                                checked_prem_list[_prem['perm_id']] = false;
                            }
                        }else{
                            prem_tpl.push('<input type="checkbox" id="prem_item_'+ _prem['perm_id'] +'" class="checkbox__ipt J_prem_item" />');

                            checked_prem_list[_prem['perm_id']] = false;
                        }
                        prem_tpl.push(_prem['perm_name']);
                        prem_tpl.push('</label>');
                    });

                    $prem_list_container.html(prem_tpl.join(''));
                }else{
                    render_error();
                }
            }).fail(function(_xhr, _status, _error) {
                render_error();
            }).always(function(_data, _status, _error) {
                get_resources_handler.abort();
                get_resources_handler = null;
            });
    }


    $prem_list_container.on('click.reload', 'a.J_btn_reload', get_prem_list);

    $prem_list_container.on('click.reload', 'input.J_prem_item', function(){
        checked_prem_list[this.id.replace('prem_item_', '')] = this.checked;
    });

    return {
        init: function(_role_id){
            if(_role_id==null){
                ArtDialog({
                    'skin': 'dialog-confirm',
                    'title': '温馨提示',
                    'content': '<p class="confirm-cnt">无此角色，请返回角色列表核对!</p>',
                    'modal': true,
                    'okValue': "确定",
                    'ok': function(){
                        window.location.href = '/school/route/administration/role';
                        this.content('<p class="confirm-cnt">正在返回角色列表，请稍后!</p>');
                        return false;
                    }
                }).show();
                return false;
            }
            get_role_prem_list(_role_id, function(_checked_prem_list){
                get_prem_list(_checked_prem_list);
            });
        },
        result: function(){
            var result = [];
            $.each(checked_prem_list, function(_prem_id, _prem_status){
                if(_prem_status==true){
                    result.push(_prem_id);
                }
            });
            return result.join(',');
        },
        reset: function(){
            var reset_list = checked_prem_id_list_reset.concat([]);
            $.each(checked_prem_list, function(_prem_id){
                var is_checked = false;

                if(reset_list.length){
                    $.each(reset_list, function(_index, _checked_id){
                        if(_checked_id == _prem_id){
                            is_checked = true;
                            reset_list.splice(_index, 1);
                        }
                    })
                }

                $('#prem_item_'+_prem_id).prop('checked', is_checked);
                checked_prem_list[_prem_id] = is_checked;
            })
        }
    }
})();

PremList.init(ROLE_ID);

var modify_role_prem_handler = null;
$('#role_form').on('submit', function(){
    if(modify_role_prem_handler!==null){
        return;
    }

    ArtDialog({
        'skin': 'dialog-confirm',
        'title': '温馨提示',
        'content': '<p class="confirm-cnt">您正在修改角色权限，请确认!</p>',
        'modal': true,
        'okValue': "确定",
        'ok': function(){
            var dialog = this;
            dialog.content('<p class="confirm-cnt">正在提交修改请求，请稍后!</p>');

            modify_role_prem_handler = $.post('/school/pmc/rela/_modifyRolePermission', {
                'roleId': ROLE_ID,
                'permissionIDs': PremList.result()
            }).done(function(_data, _status, _xhr){
                if(parseInt(_data['code'], 10)===0){
                    dialog.content('<p class="confirm-cnt success">权限修改成功!</p>');
                }else{
                    dialog.content('<p class="confirm-cnt error">权限修改失败，请重试!</p>');
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.content('<p class="confirm-cnt error">权限修改失败，请重试!</p>');
            }).always(function(_data, _status, _error) {
                modify_role_prem_handler.abort();
                modify_role_prem_handler = null;

                dialog.button([
                    {
                        value: '关闭',
                        autofocus: true,
                        callback: function(){
                            return true;
                        }
                    }
                ]);
            });

            return false;
        }
    }).show();
    return false;
});

$('#prem_form_reset').on('click.reset', function(){
    ArtDialog({
        'skin': 'dialog-confirm',
        'title': '温馨提示',
        'content': '<p class="confirm-cnt">您正在重置角色权限，请确认!</p>',
        'modal': true,
        'okValue': "确定",
        'ok': function(){
            PremList.reset();
            return true;
        }
    }).show();
    return false;
})
</script>

</body>
</html>
