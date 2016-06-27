<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能控制-运维管理-网关管理</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="./operation.scss" charset="utf-8">

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
                <span class="breadcrumb-active">运维管理</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">网关管理</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;网关总览</span>
                    </div>
                    <div class="panel__body">
                        <!-- <div class="panel-toolbar">
                            <div class="ui-search-group">
                                <label for="" class="search-label">快速检索：</label>
                                <input type="text" class="ui-input search__item_first" value="" placeholder="网关检索">
                                <a href="javascript:void(0);" class="ui-button ui-button-sm search__item_last"><i class="fa fa-search"></i></a>
                            </div>
                        </div> -->
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="新增" id="gateway_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                            </div>
                            <table class="ui-table" id="gateway_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width: 30px;">序号</th>
                                        <th>网关名称</th>
                                        <th>网关MAC</th>
                                        <th>描述</th>
                                        <th style="width: 60px;">状态</th>
                                        <th style="width: 80px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="gateway_list_paging"></div>
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
    SidebarMenu.init('operation', 'gateway');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js'),
    SelectDict = require('/components/select-option/service.js');

var Gateway_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_gateway_no, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
            if(__item['gateway_no']==_gateway_no){
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

        get_resources_handler = $.getJSON('/school/V1/DeviceService/_findPage', {
            bizType: 'gateway',
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="gateway_item_'+ __item['gateway_no'] +'">',
                    '<td><input type="checkbox" class="J_select_one" data-gateway-no="'+ __item['gateway_no'] +'"></td>',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td class="J_item_code">'+ __item['gateway_code'] +'</td>',
                    '<td class="J_item_mac">'+ __item['mac'] +'</td>',
                    '<td class="J_item_memo">'+ __item['gateway_memo'] +'</td>',
                    '<td class="J_item_status">'+ ((parseInt(__item['gateway_status'], 10)===0) ? '启用' : '禁用') +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="编辑" data-gateway-no="'+ __item['gateway_no'] +'"><i class="fa fa-edit"></i>&nbsp;编辑</a>',
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }
    function update_item(_gateway_no, _data){
        var $item = $('#gateway_item_'+_gateway_no);
        if($item.length){
            $item.find('td.J_item_code').eq(0).html(_data['gateway_code']);
            $item.find('td.J_item_memo').eq(0).html(_data['gateway_memo']);
            $item.find('td.J_item_mac').eq(0).html(_data['mac']);
            $item.find('td.J_item_status').eq(0).html((parseInt(_data['gateway_status'], 10)===0) ? '启用' : '禁用');

            // update data
            find_by_no(_gateway_no, function(_index){
                data['result'][_index]['gateway_code'] = _data['gateway_code'];
                data['result'][_index]['gateway_memo'] = _data['gateway_memo'];
                data['result'][_index]['mac'] = _data['mac'];
                data['result'][_index]['gateway_status'] = _data['gateway_status'];
            });
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
                (!!_data['result'] && _data['result'].length>0) && Paging.init('gateway_list_paging', {
                    pageNo:  _data['pageNo'],
                    totalPages: _data['totalPages'],
                    pageSize: _data['pageSize'],
                    records: _data['records']
                })
            });

            // 绑定编辑事件
            $content.on('click.edit', 'a.J_btn_edit', function(){
                var item_data = find_by_no($(this).data('gateway-no'));

                var $gateway_code = null,
                    $gateway_memo = null,
                    $gateway_status = null,
                    $gateway_mac = null;

                var edit_handler = null;
                function check(){
                    return ($.trim($gateway_code.val()).length!==0) && ($.trim($gateway_mac.val()).length!==0);
                }

                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '编辑网关信息',
                    'content': [
                        '<div class="">',
                            '<div class="form-group">',
                                '<label for="" class="group__label">网关编号:</label>',
                                '<span class="group__text">'+ item_data['gateway_no'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*网关名称:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_gateway_code" value="'+ item_data['gateway_code'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*MAC:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_gateway_mac" value="'+ item_data['mac'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">网关描述:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_gateway_memo" value="'+ item_data['gateway_memo'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*网关状态:</label>',
                                '<select class="ui-select group__control J_dialog_gateway_status">',
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
                            bizType: 'gateway',
                            no: item_data['gateway_no'],
                            gateway_code: $gateway_code.val(),
                            mac: $gateway_mac.val(),
                            gateway_memo: $gateway_memo.val(),
                            gateway_status: $gateway_status.val()
                        };

                        edit_handler = $.post('/school/V1/DeviceService/_modifyRecord', update_params).done(function(_data, _status, _xhr){
                            if(parseInt(_data['code'], 10)===0){
                                update_item(item_data['gateway_no'], update_params);

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
                                dialog.title('编辑网关信息');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip danger">',
                                        '<i class="fa fa-info-circle"></i>&nbsp;',
                                        _data['msg'],
                                    '</div>'
                                ].join(''));
                            }
                        }).fail(function(_xhr, _status, _error) {
                            dialog.title('编辑网关信息');
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
                        $gateway_code = $(this.node).find('input.J_dialog_gateway_code').eq(0);
                        $gateway_memo = $(this.node).find('input.J_dialog_gateway_memo').eq(0);
                        $gateway_mac = $(this.node).find('input.J_dialog_gateway_mac').eq(0);
                        $gateway_status = $(this.node).find('select.J_dialog_gateway_status').eq(0);

                        $gateway_status.val(item_data['gateway_status']);

                        $gateway_code.on('change focus', function(){
                            dialog.statusbar(null);
                        });
                        $gateway_mac.on('change focus', function(){
                            dialog.statusbar(null);
                        });
                        $gateway_status.on('change focus', function(){
                            dialog.statusbar(null);
                        });
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

Gateway_list.init('gateway_list', {
    page_no: Url('?pageNo') || 1,
    page_limit: Url('?pageSize') || 10
});


// 绑定新增事件
$('#gateway_add').on('click.add', function(){
    var $gateway_code = null,
        $gateway_memo = null,
        $gateway_status = null,
        $gateway_mac = null;

    var add_handler = null;
    function check(){
        return ($.trim($gateway_code.val()).length!==0) && ($.trim($gateway_mac.val()).length!==0);
    }

    ArtDialog({
        'skin': 'dialog-form',
        'modal': true,
        'title': '新增网关',
        'content': [
            '<div class="">',
                '<div class="form-group">',
                    '<label for="" class="group__label">*网关名称:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_gateway_code" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*MAC:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_gateway_mac" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">网关描述:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_gateway_memo" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*网关状态:</label>',
                    '<select class="ui-select group__control J_dialog_gateway_status">',
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
            var add_params = {
                bizType: 'gateway',
                gateway_code: $gateway_code.val(),
                mac: $gateway_mac.val(),
                gateway_memo: $gateway_memo.val(),
                gateway_status: $gateway_status.val()
            };

            add_handler = $.post('/school/V1/DeviceService/_addRecord', add_params).done(function(_data, _status, _xhr){
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
                    dialog.title('新增网关');
                    dialog.statusbar([
                        '<div class="dialog-form-tip danger">',
                            '<i class="fa fa-info-circle"></i>&nbsp;',
                            _data['msg'],
                        '</div>'
                    ].join(''));
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.title('新增网关');
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
            $gateway_code = $(this.node).find('input.J_dialog_gateway_code').eq(0);
            $gateway_memo = $(this.node).find('input.J_dialog_gateway_memo').eq(0);
            $gateway_mac = $(this.node).find('input.J_dialog_gateway_mac').eq(0);
            $gateway_status = $(this.node).find('select.J_dialog_gateway_status').eq(0);

            $gateway_code.on('change focus', function(){
                dialog.statusbar(null);
            });
            $gateway_mac.on('change focus', function(){
                dialog.statusbar(null);
            });
            $gateway_status.on('change focus', function(){
                dialog.statusbar(null);
            });
        }
    }).show();
});
</script>

</body>
</html>
