<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能控制-房间控制-房间设备</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="../controller.scss" charset="utf-8">

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
                <span class="breadcrumb-active">智能控制</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">房间控制</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">房间设备</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <a href="javascript:void(0);" class="ui-button ui-button-sm fn-right" title="返回" id="back_to_list"><i class="fa fa-undo"></i>&nbsp;返回</a>
                        <span class="panel-title"><i class="fa fa-inbox"></i>&nbsp;房间设备</span>
                    </div>
                    <div class="panel__body">
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <h5 class="toolbar__title" id="room_name">&nbsp;</h5>
                            </div>
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="一键全开" id="room_device_open_multi"><i class="fa fa-toggle-on"></i>&nbsp;一键全开</a>
                                <a href="javascript:void(0);" class="ui-button ui-button-sm" title="一键全关" id="room_device_close_multi">一键全关&nbsp;<i class="fa fa-toggle-off"></i></a>
                            </div>
                            <table class="ui-table" id="room_device_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width:30px;">序号</th>
                                        <th>设备名</th>
                                        <th>节点MAC</th>
                                        <th style="width:60px;">状态</th>
                                        <th style="width:100px;">设备读数</th>
                                        <th style="width:120px;">操作</th>
                                    </tr>
                                </thead><!-- 表头可选 -->
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
    SidebarMenu.init('controller', 'room');
});

var ArtDialog = require('dialog'),
    Url = require('url');

var room_name = Url('?name') || null;
if(room_name!==null){
    $('#room_name').html(window.decodeURI(room_name));
}

var MULTI_SWITCHER_HANDLER = null;
function multi_switch(_status, _ids, _callback){
    if(MULTI_SWITCHER_HANDLER!==null){
        return false;
    }
    if(!_ids || _ids.length===0){
        ArtDialog({
            'skin': 'dialog-confirm',
            'title': '温馨提示',
            'content': '<p class="confirm-cnt">请先选择需要操作的记录!</p>',
            'modal': true,
            'okValue': "确定",
            'ok': $.noop
        }).show();
        return false;
    }
    var status_cn = !_status ? '关闭' : '开启',
        status_code = !_status ? 'OFF' : 'ON';
    ArtDialog({
        'skin': 'dialog-confirm',
        'title': '温馨提示',
        'content': '<p class="confirm-cnt">您是否需要'+status_cn+'这'+ _ids.length +'条记录？</p>',
        'statusbar': [
            '<div class="dialog-form-tip danger">&nbsp;</div>'
        ].join(''),
        'modal': true,
        'okValue': "确定",
        'ok': function(){
            var dialog = this;

            dialog.button([
                    {
                        id: 'ok',
                        value: '正在处理...',
                        autofocus: true,
                        disabled: true
                    }
                ]);

            MULTI_SWITCHER_HANDLER = $.post('/school/V1/ControllerService/_deviceControllerByRoom', {
                ControllerStatus: status_code,
                no: _ids.join(',')
            }).done(function(_data, _status, _xhr){
                if(parseInt(_data['code'], 10)===0){
                    dialog
                        .statusbar([
                            '<div class="dialog-form-tip success">',
                                '<i class="fa fa-check-circle"></i>&nbsp;操作成功！',
                            '</div>'
                        ].join(''))
                        .button([
                            {
                                value: '关闭',
                                autofocus: true,
                                callback: function(){
                                    $.isFunction(_callback) && _callback();
                                    window.location.reload();
                                    return false;
                                }
                            }
                        ]);
                }else{
                    dialog
                        .statusbar([
                            '<div class="dialog-form-tip danger">',
                                '<i class="fa fa-info-circle"></i>&nbsp;',
                                _data['msg'],
                            '</div>'
                        ].join(''))
                        .button([
                            {
                                value: '关闭',
                                autofocus: true,
                                callback: function(){
                                    return true;
                                }
                            }
                        ]);
                }
            }).fail(function(_xhr, _status, _error) {
                dialog
                    .statusbar([
                            '<div class="dialog-form-tip danger">',
                                '<i class="fa fa-info-circle"></i>&nbsp;网络异常，请再试一次',
                            '</div>'
                        ].join(''))
                    .button([
                            {
                                value: '关闭',
                                autofocus: true,
                                callback: function(){
                                    return true;
                                }
                            }
                        ]);
            }).always(function(_data, _status, _error) {
                MULTI_SWITCHER_HANDLER.abort();
                MULTI_SWITCHER_HANDLER = null;
            });
            return false;
        },
        cancelValue: '取消'
    }).show();
}

var Room_device_list = (function(){

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_device_no, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
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

        get_resources_handler = $.getJSON('/school/V1/ControllerService/_roomDetail', {
            no: _room_no
        }).done(function(_data, _status, _xhr){
            if(parseInt(_data['code'], 10)===0){
                data = _data;

                render_data(_data['result']);

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
    function render_data(_result){
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
        // <th style="width:30px;">序号</th>
        // <th>设备名</th>
        // <th>MAC地址</th>
        // <th style="width:60px;">状态</th>
        // <th style="width:100px;">设备读数</th>
        // <th style="width:120px;">操作</th>
        var tpl = [];
        $.each(_result, function(__index, __item){
            tpl.push([
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="room_device_'+ __item['device_no'] +'">',
                    '<td>',
                        ((parseInt(__item['device_type'], 10)<4)?[
                            '<input type="checkbox" class="J_select_one" data-device-no="'+ __item['device_no'] +'" data-device-level="'+ __item['device_level'] +'" data-node-mac="'+ __item['node_mac'] +'">'
                        ].join(''):[
                            '<input type="checkbox" disabled>'
                        ].join('')),
                    '</td>',
                    '<td>'+ (__index+1) +'</td>',
                    '<td>'+ __item['device_name'] +'</td>',
                    '<td>'+ __item['node_mac'] +'</td>',
                    '<td>'+ ((parseInt(__item['device_status'])===0)?'开启':'关闭') +'</td>',
                    '<td class="ui-text-success">'+ __item['device_number'] +'</td>',
                    '<td>',
                        ((parseInt(__item['device_type'], 10)<4)?[
                            '<a href="javascript:void(0);" class="ui-button-switcher J_btn_switcher" data-device-no="'+ __item['device_no'] +'" data-device-level="'+ __item['device_level'] +'" data-node-mac="'+ __item['node_mac'] +'">',
                                '<span class="switcher__btn J_btn_switcher_on'+ ((parseInt(__item['device_status'], 10)===0)?' actived':'') +'" title="开启"><i class="fa fa-toggle-on"></i>&nbsp;开启</span>',
                                '<span class="switcher__btn J_btn_switcher_off'+ ((parseInt(__item['device_status'], 10)!==0)?' actived':'') +'" title="关闭">关闭&nbsp;<i class="fa fa-toggle-off"></i></span>',
                            '</a>'
                        ].join(''):'&nbsp;'),
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }
    function update_item(_device_no, _data){
        var $item = $('#room_device_'+_device_no);
        if($item.length){
            $item.find('td.J_item_open_num').eq(0).html(_data['openNum']);
            $item.find('td.J_item_close_num').eq(0).html(_data['closeNum']);

            // update data
            find_by_no(_device_no, function(_index){
                data['result'][_index]['openNum'] = _data['openNum'];
                data['result'][_index]['closeNum'] = _data['closeNum'];
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
            room_no = _params['room_no'];

            get_resources(room_no, function(){

            });

            // 绑定单个开关切换事件
            $content.on('click.delete', 'a.J_btn_switcher', function(e){
                var class_name = e.target.className;
                if(~class_name.indexOf('on')){
                    multi_switch(true, [$(this).data('device-no')+'-'+$(this).data('device-level')+'-'+$(this).data('node-mac')]);
                }else if(~class_name.indexOf('off')){
                    multi_switch(false, [$(this).data('device-no')+'-'+$(this).data('device-level')+'-'+$(this).data('node-mac')]);
                }
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
        },
        get_select_result: function (){
            var $selects = $content.find('input.J_select_one').filter(":checked"),
                result = [];
            if($selects.length){
                $selects.each(function(){
                    result.push($(this).data('device-no')+'-'+$(this).data('device-level')+'-'+$(this).data('node-mac'));
                });
            }
            return result;
        }
    };
})();

Room_device_list.init('room_device_list', {
    room_no: Url('?no')
});


$('#room_device_open_multi').on('click', function(){
    multi_switch(true, Room_device_list.get_select_result());
});
$('#room_device_close_multi').on('click', function(){
    multi_switch(false, Room_device_list.get_select_result());
});

$('#back_to_list').on('click', function(){
    var list_path = Url('?list_path') || null,
        history_back_url = (list_path!==null && list_path.length!==0) ? window.decodeURIComponent(list_path) : '/school/route/controller/room/list';
    window.location.href = history_back_url;
})
</script>

</body>
</html>
