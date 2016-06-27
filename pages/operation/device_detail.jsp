<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能控制-运维管理-设备管理</title>

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
                <span class="breadcrumb-active">设备管理</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">房间设备明细</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title" id=""><i class="fa fa-inbox"></i>&nbsp;房间设备明细</span>
                    </div>
                    <div class="panel__body">
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm fn-right" title="新增" id="device_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                                <h5 class="toolbar__title" id="room_name">&nbsp;</h5>
                            </div>
                            <table class="ui-table" id="room_device_list">
                                <thead>
                                    <tr>
                                        <th style="width:30px;">序号</th>
                                        <th>设备编码</th>
                                        <th>设备类别</th>
                                        <th>设备类型</th>
                                        <th>设备描述</th>
                                        <th>所属节点</th>
                                        <th>节点MAC</th>
                                        <th style="width:60px;">状态</th>
                                        <th style="width:80px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
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
    SidebarMenu.init('operation', 'device');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    NodeTypeDict = require('/components/select-option/nodetype.js');

var ROOM_NAME = Url('?name') || null;
if(ROOM_NAME!==null){
    $('#room_name').html(window.decodeURI(ROOM_NAME));
}
var ROOM_NO = Url('?no') || null;

var Room_device_list = (function(){

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_device_no, _callback){
        var item = null;

        $.each(data, function(__index, __item){
            if(__item['device_no']==_device_no){
                item = __item;
                $.isFunction(_callback) && _callback(__index);
                return false;
            }
        });

        return item;
    }

    var get_resources_handler = null;
    function get_resources(_room_no, _success_callback){
        if(get_resources_handler!==null){
            return false;
        }

        render_loading();

        get_resources_handler = $.getJSON('/school/V1/DeviceService/_findDeviceByRoom', {
            no: _room_no
        }).done(function(_data, _status, _xhr){
            if(parseInt(_data['code'], 10)===0){
                data = _data['dataObject'];

                render_data(_data['dataObject']);

                $.isFunction(_success_callback) && _success_callback(_data['dataObject']);
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
    function render_data(_result){
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="room_device_'+ __item['device_no'] +'">',
                    '<td>'+ (__index+1) +'</td>',
                    '<td class="J_item_device_code">'+ __item['device_code'] +'</td>',
                    '<td class="J_item_device_level_name">'+ __item['device_level_name'] +'</td>',
                    '<td class="J_item_device_type_name">'+ __item['device_type_name'] +'</td>',
                    '<td class="J_item_device_memo">'+ __item['device_memo'] +'</td>',
                    '<td class="J_item_node_name">'+ __item['node_name'] +'</td>',
                    '<td class="J_item_node_mac">'+ __item['node_mac'] +'</td>',
                    '<td class="J_item_device_status">'+ ((parseInt(__item['device_status'])===0)?'启用':'禁用') +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" data-device-no="'+ __item['device_no'] +'"><i class="fa fa-edit"></i>&nbsp;编辑',
                        '</a>',
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }
    function update_item(_device_no, _data){
        var $item = $('#room_device_'+_device_no);
        if($item.length){
            $item.find('td.J_item_device_code').eq(0).html(_data['device_code']);
            $item.find('td.J_item_device_level_name').eq(0).html(_data['device_level_name']);
            $item.find('td.J_item_device_type_name').eq(0).html(_data['device_type_name']);
            $item.find('td.J_item_device_memo').eq(0).html(_data['device_memo']);
            $item.find('td.J_item_node_mac').eq(0).html(_data['node_mac']);
            console.log($item.find('td.J_item_device_status').eq(0));
            console.log((parseInt(_data['device_status'], 10)===0) ? '启用' : '禁用');
            $item.find('td.J_item_device_status').eq(0).html((parseInt(_data['device_status'], 10)===0) ? '启用' : '禁用');

            // update data
            find_by_no(_device_no, function(_index){
                $.each(_data, function(_key, _val){
                    (data[_index][_key]!==undefined) && (data[_index][_key] = _val);
                });
            })
        }
    }

    return {
        init: function(_$table_id, _params){
            $container = $('#'+_$table_id);
            $content = $container.children('tbody').eq(0);
            room_no = _params['room_no'];

            get_resources(room_no, $.noop);

            // 绑定单个开关切换事件
            $content.on('click.edit', 'a.J_btn_edit', function(e){
                var item_data = find_by_no($(this).data('device-no'));

                var $device_level = null,
                    $device_type = null,
                    $device_code = null,
                    $node_mac = null,
                    $device_memo = null,
                    $device_status = null;

                var edit_handler = null;
                function check(){
                    return (!!$device_level.val() && ($device_level.val()+'')!=='0') && (!!$device_type.val() && ($device_type.val()+'')!=='0') && ($.trim($device_code.val()).length!==0) && ($.trim($node_mac.val()).length!==0);
                }

                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '编辑设备信息',
                    'content': [
                        '<div class="">',
                            '<div class="form-group">',
                                '<label for="" class="group__label">设备编号:</label>',
                                '<span class="group__text">'+ item_data['device_no'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*设备类别:</label>',
                                '<select class="ui-select group__control J_dialog_device_level">',
                                    '<option value="0">请选择设备类别</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*设备类型:</label>',
                                '<select class="ui-select group__control J_dialog_device_type">',
                                    '<option value="0">请选择设备类型</option>',
                                '</select>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*设备编码:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_device_code" value="'+ item_data['device_code'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*节点MAC:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_node_mac" value="'+ item_data['node_mac'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">设备描述:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_device_memo" value="'+ item_data['device_memo'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*设备状态:</label>',
                                '<select class="ui-select group__control J_dialog_device_status">',
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
                            bizType: 'device',
                            no: item_data['device_no'],
                            room_no: item_data['room_no'],
                            node_mac: $node_mac.val(),
                            device_code : $device_code.val(),
                            device_memo : $device_memo.val(),
                            device_status : $device_status.val(),
                            device_level : $device_level.val(),
                            device_type : $device_type.val()
                        };

                        edit_handler = $.post('/school/V1/DeviceService/_modifyRecord', update_params).done(function(_data, _status, _xhr){
                            if(parseInt(_data['code'], 10)===0){
                                update_item(
                                    item_data['node_no'],
                                    $.extend({}, update_params,
                                        {
                                            device_type_name: $device_type.children('option[value=\''+ update_params['device_type'] +'\']').text(),
                                            device_level_name: $device_level.children('option[value=\''+update_params['device_level'] +'\']').text()
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

                        $device_level = $(this.node).find('select.J_dialog_device_level').eq(0);
                        $device_type = $(this.node).find('select.J_dialog_device_type').eq(0);
                        $device_code = $(this.node).find('input.J_dialog_device_code').eq(0);
                        $node_mac = $(this.node).find('input.J_dialog_node_mac').eq(0);
                        $device_memo = $(this.node).find('input.J_dialog_device_memo').eq(0);
                        $device_status = $(this.node).find('select.J_dialog_device_status').eq(0);

                        $device_status.val(item_data['device_status']);

                        NodeTypeDict.get({
                            bizType: 'deviceType'
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _option){
                                options.push('<option value="'+ _option['value'] +'">'+ _option['name'] +'</option>')
                            });
                            $device_type.append(options.join('')).val(item_data['device_type']);
                        });

                        NodeTypeDict.get({
                            bizType: 'deviceLevel'
                        }, function(_data){
                            var options = [];
                            $.each(_data, function(_i, _option){
                                options.push('<option value="'+ _option['value'] +'">'+ _option['name'] +'</option>')
                            });
                            $device_level.append(options.join('')).val(item_data['device_level']);
                        });

                        $(this.node).on('change focus', 'input select', function(){
                            dialog.statusbar(null);
                        });
                    }
                }).show();
            });

            $content.on('click.edit', 'a.J_btn_reload', function(){
                window.location.reload();
            });
        }
    };
})();

Room_device_list.init('room_device_list', {
    room_no: Url('?no')
});

// 绑定新增事件

$('#device_add').on('click.add', function(){
    var $device_level = null,
        $device_type = null,
        $device_code = null,
        $node_mac = null,
        $device_memo = null,
        $device_status = null;

    var edit_handler = null;
    function check(){
        return (!!$device_level.val() && ($device_level.val()+'')!=='0') && (!!$device_type.val() && ($device_type.val()+'')!=='0') && ($.trim($device_code.val()).length!==0) && ($.trim($node_mac.val()).length!==0);
    }

    ArtDialog({
        'skin': 'dialog-form',
        'modal': true,
        'title': '新增设备',
        'content': [
            '<div class="">',
                '<div class="form-group">',
                    '<label for="" class="group__label">*设备类别:</label>',
                    '<select class="ui-select group__control J_dialog_device_level">',
                        '<option value="0">请选择设备类别</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*设备类型:</label>',
                    '<select class="ui-select group__control J_dialog_device_type">',
                        '<option value="0">请选择设备类型</option>',
                    '</select>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*设备编码:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_device_code" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*节点MAC:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_node_mac" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">设备描述:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_device_memo" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*设备状态:</label>',
                    '<select class="ui-select group__control J_dialog_device_status">',
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
                bizType: 'device',
                room_no: ROOM_NO,
                node_mac: $node_mac.val(),
                device_code : $device_code.val(),
                device_memo : $device_memo.val(),
                device_status : $device_status.val(),
                device_level : $device_level.val(),
                device_type : $device_type.val()
            };

            edit_handler = $.post('/school/V1/DeviceService/_addRecord', update_params).done(function(_data, _status, _xhr){
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
                    dialog.title('新增设备');
                    dialog.statusbar([
                        '<div class="dialog-form-tip danger">',
                            '<i class="fa fa-info-circle"></i>&nbsp;',
                            _data['msg'],
                        '</div>'
                    ].join(''));
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.title('新增设备');
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

            $device_level = $(this.node).find('select.J_dialog_device_level').eq(0);
            $device_type = $(this.node).find('select.J_dialog_device_type').eq(0);
            $device_code = $(this.node).find('input.J_dialog_device_code').eq(0);
            $node_mac = $(this.node).find('input.J_dialog_node_mac').eq(0);
            $device_memo = $(this.node).find('input.J_dialog_device_memo').eq(0);
            $device_status = $(this.node).find('select.J_dialog_device_status').eq(0);

            NodeTypeDict.get({
                bizType: 'deviceType'
            }, function(_data){
                var options = [];
                $.each(_data, function(_i, _option){
                    options.push('<option value="'+ _option['value'] +'">'+ _option['name'] +'</option>')
                });
                $device_type.append(options.join(''));
            });

            NodeTypeDict.get({
                bizType: 'deviceLevel'
            }, function(_data){
                var options = [];
                $.each(_data, function(_i, _option){
                    options.push('<option value="'+ _option['value'] +'">'+ _option['name'] +'</option>')
                });
                $device_level.append(options.join(''));
            });

            $(this.node).on('change focus', 'input select', function(){
                dialog.statusbar(null);
            });
        }
    }).show();
});


</script>

</body>
</html>
