<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能告警-告警信息</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="./alam.scss" charset="utf-8">

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
                <span class="breadcrumb-active">智能告警</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">告警信息</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;告警信息列表</span>
                    </div>
                    <div class="panel__body">
                        <div class="panel-toolbar">
                            <div class="panel-toolbar-subtab" id="alam_status_tabs">
                                范围：<a href="/school/route/alam/list" class="subtab__item" data-alam-status="all">全部</a>&nbsp;&#124;&nbsp;<a href="/school/route/alam/list?alam_status=1" class="subtab__item" data-alam-status="1">已处理</a>&nbsp;&#124;&nbsp;<a href="/school/route/alam/list?alam_status=0" class="subtab__item" data-alam-status="0">未处理</a>
                            </div>
                            <!-- <div class="ui-search-group">
                                <label for="" class="search-label">快速检索：</label>
                                <div class="search__item_first">
                                    <select name="" id="" class="ui-form-select J_ui_select">
                                        <option value="0">请选择楼宇</option>
                                        <option value="1">1号楼</option>
                                        <option value="2">2号楼</option>
                                        <option value="3">3号楼</option>
                                    </select>
                                </div>
                                <div class="search__item">
                                    <select name="" id="" class="ui-form-select J_ui_select">
                                        <option value="0">请选择楼层</option>
                                        <option value="1">1楼</option>
                                        <option value="2">2楼</option>
                                        <option value="3">3楼</option>
                                    </select>
                                </div>
                                <div class="search__item">
                                    <select name="" id="" class="ui-form-select J_ui_select">
                                        <option value="0">请选择房间</option>
                                        <option value="1">101室</option>
                                        <option value="2">201室</option>
                                        <option value="3">301室</option>
                                    </select>
                                </div>
                                <input type="text" class="ui-input search__item" value="" placeholder="床位检索">
                                <a href="javascript:void(0);" class="ui-button ui-button-sm search__item_last"><i class="fa fa-search"></i></a>
                            </div> -->
                        </div>
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button ui-button-sm fn-right" title="刷新" id="alam_refresh"><i class="fa fa-refresh"></i>&nbsp;刷新</a>
                            </div>
                            <table class="ui-table" id="alam_list">
                                <thead>
                                    <tr>
                                        <th style="width: 30px;">序号</th>
                                        <th>楼宇名称</th>
                                        <th>楼层名称</th>
                                        <th>房间名称</th>
                                        <th>节点MAC</th>
                                        <th>设备类型</th>
                                        <th>告警信息</th>
                                        <th style="width: 65px;">告警时间</th>
                                        <th>处理备注</th>
                                        <th style="width: 100px;">操作</th>
                                    </tr>
                                </thead><!-- 表头可选 -->
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="alam_list_paging"></div>
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
    SidebarMenu.init('alam', 'list');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js');


var ALAM_STATUS = Url('?alam_status') || 'all';

$('#alam_status_tabs').find('a.subtab__item').each(function(){
    if($(this).data('alam-status')==ALAM_STATUS){
        $(this).addClass('actived');
    }
});

var Alam_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_alam_no, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
            if(__item['record_no']==_alam_no){
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

        var list_params = {
                pageNo: page_next,
                pageSize: page_limit
            };
        if(~~ALAM_STATUS.indexOf('all')!==0){
            list_params['alam_status'] = ALAM_STATUS;
        }

        get_resources_handler = $.getJSON('/school/V1/AlamService/_findAlamPage', list_params).done(function(_data, _status, _xhr){
            if(parseInt(_data['code'], 10)===300){
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="alam_item_'+ __item['record_no'] +'">',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td>'+ __item['building_name'] +'</td>',
                    '<td>'+ __item['level_name'] +'</td>',
                    '<td>'+ __item['room_name'] +'</td>',
                    '<td>'+ __item['node_mac'] +'</td>',
                    '<td>'+ __item['deviceTypeName'] +'</td>',
                    '<td>'+ __item['alam_info'] +'</td>',
                    '<td>'+ __item['alam_time'] +'</td>',
                    '<td class="J_item_handle_info">'+ (__item['handle_info'] || '&nbsp;') +'</td>',
                    '<td>',
                        ((parseInt(__item['alam_status'], 10)===1) ? '<span class="ui-text-success">已处理</span>' : '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="立即处理" data-record-no="'+ __item['record_no'] +'"><i class="fa fa-edit"></i>&nbsp;立即处理</a>'),
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }

    return {
        init: function(_$table_id, _params){
            $container = $('#'+_$table_id);
            $content = $container.children('tbody').eq(0);
            page_no = _params['page_no'];
            page_limit = _params['page_limit'];

            get_resources(page_no, function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('alam_list_paging', {
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

                var $handle_info = null;

                var edit_handler = null;
                function check(){
                    return ($.trim($handle_info.val()).length !== 0);
                }

                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '提交告警反馈',
                    'content': [
                        '<div class="">',
                            '<div class="form-group">',
                                '<label for="" class="group__label">告警编号:</label>',
                                '<span class="group__text">'+ item_data['record_no'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*级别名称:</label>',
                                '<textarea class="ui-input group__control J_dialog_handle_info"></textarea>',
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
                            record_no: item_data['record_no'],
                            alam_status: '1',
                            handle_info: $handle_info.val(),
                            node_mac: item_data['node_mac']
                        };
                        edit_handler = $.post('/school/V1/AlamService/_alamHandle', update_params).done(function(_data, _status, _xhr){
                            if(parseInt(_data['code'], 10)===0){
                                dialog.title('反馈成功');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip success">',
                                        '<i class="fa fa-check-circle"></i>&nbsp;反馈成功！',
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
                                dialog.title('提交告警反馈');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip danger">',
                                        '<i class="fa fa-info-circle"></i>&nbsp;',
                                        _data['msg'],
                                    '</div>'
                                ].join(''));
                            }
                        }).fail(function(_xhr, _status, _error) {
                            dialog.title('提交告警反馈');
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

                        $handle_info = $(this.node).find('textarea.J_dialog_handle_info').eq(0);

                        $handle_info.on('change focus', 'input select', function(){
                            dialog.statusbar(null);
                        });
                    }
                }).show();
            });
        }
    };
})();

Alam_list.init('alam_list', {
    page_no: Url('?pageNo') || 1,
    page_limit: Url('?pageSize') || 10
});

$('#alam_refresh').on('click', function(){
    window.location.reload();
});

</script>

</body>
</html>
