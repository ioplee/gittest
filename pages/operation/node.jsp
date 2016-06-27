<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能控制-运维管理-节点管理</title>

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
                <span class="breadcrumb-active">节点管理</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;节点总览</span>
                    </div>
                    <div class="panel__body">
                        <div class="panel-toolbar">
                            <div class="ui-search-group">
                                <label for="" class="search-label">快速检索：</label>
                                <input type="text" class="ui-input search__item_first" value="" placeholder="节点检索" id="search_text">
                                <a href="javascript:void(0);" class="ui-button ui-button-sm search__item_last" id="search_submit"><i class="fa fa-search"></i></a>
                            </div>
                        </div>
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="新增" id="node_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                            </div>
                            <table class="ui-table" id="node_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width: 30px;">序号</th>
                                        <th>节点名称</th>
                                        <th>网关编码</th>
                                        <th>设备类型</th>
                                        <th>节点MAC</th>
                                        <th style="width: 60px;">状态</th>
                                        <th style="width: 80px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="node_list_paging"></div>
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
    SidebarMenu.init('operation', 'node');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js'),
    SelectDict = require('/components/select-option/service.js'),
    NodeTypeDict = require('/components/select-option/nodetype.js');

var SEARCH_NODE_MAC = Url('?node_mac') || null;

var Node_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_node_no, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
            if(__item['node_no']==_node_no){
                item = __item;
                $.isFunction(_callback) && _callback(__index);
                return false;
            }
        });

        return item;
    }

    var get_resources_handler = null;
    function get_resources(_page_next, _node_mac, _success_callback){
        if(get_resources_handler!==null){
            return false;
        }

        render_loading();

        var page_next = _page_next || page_no;
        page_next = (page_next<=0) ? 1 : ((page_total===null) || (page_next<=page_total)) ? page_next : page_total;
        page_no = page_next;

        var resource_params = {
            bizType: 'node',
            pageNo: page_next,
            pageSize: page_limit
        };
        if(_node_mac!==null){
            resource_params['node_mac'] = _node_mac;
        }

        get_resources_handler = $.getJSON('/school/V1/DeviceService/_findPage', resource_params).done(function(_data, _status, _xhr){
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="node_item_'+ __item['node_no'] +'">',
                    '<td><input type="checkbox" class="J_select_one" data-node-no="'+ __item['node_no'] +'"></td>',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td class="J_item_name">'+ __item['node_name'] +'</td>',
                    '<td class="J_item_gateway">'+ __item['gateway_code'] +'</td>',
                    '<td class="J_item_type">'+ __item['typeName'] +'</td>',
                    '<td class="J_item_mac">'+ __item['node_mac'] +'</td>',
                    '<td class="J_item_status">'+ ((parseInt(__item['node_status'], 10)===0) ? '启用' : '禁用') +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="编辑" data-node-no="'+ __item['node_no'] +'"><i class="fa fa-edit"></i>&nbsp;编辑</a>',
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }
    function update_item(_node_no, _data){
        // node_name: $node_name.val(),
        // node_mac: $node_mac.val(),
        // node_type: $node_type.val(),
        // node_status: $node_status.val(),
        // gateway_no: $gateway.val()
        var $item = $('#node_item_'+_node_no);
        if($item.length){
            $item.find('td.J_item_name').eq(0).html(_data['node_name']);
            $item.find('td.J_item_mac').eq(0).html(_data['node_mac']);
            $item.find('td.J_item_type').eq(0).html(_data['typeName']);
            $item.find('td.J_item_gateway').eq(0).html(_data['gateway_code']);
            $item.find('td.J_item_status').eq(0).html((parseInt(_data['node_status'], 10)===0) ? '启用' : '禁用');

            // update data
            find_by_no(_node_no, function(_index){
                $.each(_data, function(_key, _val){
                    (data['result'][_index][_key]!==undefined) && (data['result'][_index][_key] = _val);
                });
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

            get_resources(page_no, _params['node_mac'], function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('node_list_paging', {
                    pageNo:  _data['pageNo'],
                    totalPages: _data['totalPages'],
                    pageSize: _data['pageSize'],
                    records: _data['records']
                })
            });

            // 绑定编辑事件
            $content.on('click.edit', 'a.J_btn_edit', function(){
                var item_data = find_by_no($(this).data('node-no'));

                var $node_name = null,
                    $gateway = null,
                    $node_type = null,
                    $node_status = null,
                    $node_mac = null;

                var edit_handler = null;
                function check(){
                    return ($.trim($node_name.val()).length!==0) && ($.trim($node_mac.val()).length!==0) && (!!$node_type.val() && ($node_type.val()+'')!=='0') && (!!$gateway.val() && ($gateway.val()+'')!=='0');
                }

                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '编辑节点信息',
                    'content': [
                        '<div class="">',
                            '<div class="form-group">',
                                '<label for="" class="group__label">节点编号:</label>',
                                '<span class="group__text">'+ item_data['node_no'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*节点类型:</label>',
                                '<select class="ui-select group__control J_dialog_node_type">',
                                    '<option value="0">请选择节点类型</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*所属网关:</label>',
                                '<select class="ui-select group__control J_dialog_gateway">',
                                    '<option value="0">请选择所属网关</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*节点名称:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_node_name" value="'+ item_data['node_name'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*节点MAC:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_node_mac" value="'+ item_data['node_mac'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*节点状态:</label>',
                                '<select class="ui-select group__control J_dialog_node_status">',
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
                            bizType: 'node',
                            no: item_data['node_no'],
                            node_name: $node_name.val(),
                            node_mac: $node_mac.val(),
                            device_type: $node_type.val(),
                            node_status: $node_status.val(),
                            gateway_no: $gateway.val()
                        };

                        edit_handler = $.post('/school/V1/DeviceService/_modifyRecord', update_params).done(function(_data, _status, _xhr){
                            if(parseInt(_data['code'], 10)===0){
                                update_item(
                                    item_data['node_no'],
                                    $.extend({}, update_params,
                                        {
                                            typeName: $node_type.children('option[value=\''+ update_params['device_type'] +'\']').text(),
                                            gateway_code: $gateway.children('option[value=\''+update_params['gateway_no'] +'\']').text()
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
                                dialog.title('编辑节点信息');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip danger">',
                                        '<i class="fa fa-info-circle"></i>&nbsp;',
                                        _data['msg'],
                                    '</div>'
                                ].join(''));
                            }
                        }).fail(function(_xhr, _status, _error) {
                            dialog.title('编辑节点信息');
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

                        $node_name = $(this.node).find('input.J_dialog_node_name').eq(0);
                        $gateway = $(this.node).find('select.J_dialog_gateway').eq(0);
                        $node_type = $(this.node).find('select.J_dialog_node_type').eq(0);
                        $node_status = $(this.node).find('select.J_dialog_node_status').eq(0);
                        $node_mac = $(this.node).find('input.J_dialog_node_mac').eq(0);

                        $node_status.val(item_data['node_status']);

                        NodeTypeDict.get({
                            bizType: 'nodeType'
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _option){
                                options.push('<option value="'+ _option['value'] +'">'+ _option['name'] +'</option>')
                            });
                            $node_type.append(options.join('')).val(item_data['device_type']);
                        });

                        SelectDict.get({
                            bizType: 'gateway'
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _option){
                                options.push('<option value="'+ _option['gateway_no'] +'">'+ _option['gateway_code'] +'</option>')
                            });
                            $gateway.append(options.join('')).val(item_data['gateway_no']);
                        });

                        $(this.node).on('change focus', 'input select', function(){
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

Node_list.init('node_list', {
    'page_no': Url('?pageNo') || 1,
    'page_limit': Url('?pageSize') || 10,
    'node_mac': SEARCH_NODE_MAC
});


// 绑定新增事件
$('#node_add').on('click.add', function(){
    var $node_name = null,
        $gateway = null,
        $node_type = null,
        $node_status = null,
        $node_mac = null;

    var edit_handler = null;
    function check(){
        return ($.trim($node_name.val()).length!==0) && ($.trim($node_mac.val()).length!==0) && (!!$node_type.val() && ($node_type.val()+'')!=='0') && (!!$gateway.val() && ($gateway.val()+'')!=='0');
    }

    ArtDialog({
        'skin': 'dialog-form',
        'modal': true,
        'title': '新增节点',
        'content': [
            '<div class="">',
                '<div class="form-group">',
                    '<label for="" class="group__label">*节点类型:</label>',
                    '<select class="ui-select group__control J_dialog_node_type">',
                        '<option value="0">请选择节点类型</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*所属网关:</label>',
                    '<select class="ui-select group__control J_dialog_gateway">',
                        '<option value="0">请选择所属网关</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*节点名称:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_node_name" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*节点MAC:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_node_mac" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*节点状态:</label>',
                    '<select class="ui-select group__control J_dialog_node_status">',
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
            var add_params = {
                bizType: 'node',
                node_name: $node_name.val(),
                node_mac: $node_mac.val(),
                device_type: $node_type.val(),
                node_status: $node_status.val(),
                gateway_no: $gateway.val()
            };

            edit_handler = $.post('/school/V1/DeviceService/_addRecord', add_params).done(function(_data, _status, _xhr){
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
                    dialog.title('新增节点');
                    dialog.statusbar([
                        '<div class="dialog-form-tip danger">',
                            '<i class="fa fa-info-circle"></i>&nbsp;',
                            _data['msg'],
                        '</div>'
                    ].join(''));
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.title('新增节点');
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

            $node_name = $(this.node).find('input.J_dialog_node_name').eq(0);
            $gateway = $(this.node).find('select.J_dialog_gateway').eq(0);
            $node_type = $(this.node).find('select.J_dialog_node_type').eq(0);
            $node_status = $(this.node).find('select.J_dialog_node_status').eq(0);
            $node_mac = $(this.node).find('input.J_dialog_node_mac').eq(0);

            NodeTypeDict.get({
                bizType: 'nodeType'
            }, function(_data){
                var options = [];
                $.each(_data, function(_i, _option){
                    options.push('<option value="'+ _option['value'] +'">'+ _option['name'] +'</option>')
                });
                $node_type.append(options.join(''));
            });

            SelectDict.get({
                bizType: 'gateway'
            }, function(_data){
                var options = [];
                $.each(_data, function(_i, _option){
                    options.push('<option value="'+ _option['gateway_no'] +'">'+ _option['gateway_code'] +'</option>')
                });
                $gateway.append(options.join(''));
            });

            $(this.node).on('change focus', 'input select', function(){
                dialog.statusbar(null);
            });
        }
    }).show();
});

var $search_text = $('#search_text');
$search_text.val(SEARCH_NODE_MAC);
$('#search_submit').on('click.search', function(){
    var node_mac = $.trim($search_text.val()),
        search_url = Url('path');

    if(node_mac.length !== 0){
        search_url += '?node_mac=' + node_mac;
    }

    window.location.href = search_url;
});
</script>

</body>
</html>
