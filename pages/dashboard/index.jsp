<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>Dashboard</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="dashboard.scss" charset="utf-8">

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
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-tasks"></i>&nbsp;数据统计</span>
                    </div>
                    <div class="panel__body">
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="/school/route/dashboard/overviewMore" class="ui-button ui-button-sm fn-right" title="查看全部"><i class="fa fa-ellipsis-v"></i>&nbsp;查看全部</a>
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm fn-right" title="刷新" id="refresh_overview_list"><i class="fa fa-refresh"></i>&nbsp;刷新</a>
                                <h5 class="toolbar__title">设备状态总览</h5>
                            </div>
                            <table class="ui-table" id="overview_list">
                                <thead>
                                    <tr>
                                        <th style="width:30px;">序号</th>
                                        <th>楼宇名称</th>
                                        <th>楼层名称</th>
                                        <th>房间总数</th>
                                        <th style="width:120px;">灯(使用/总数)</th>
                                        <th style="width:120px;">风扇(使用/总数)</th>
                                        <th style="width:120px;">插座(使用/总数)</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>

                        <div class="dashboard-table-box">
                            <div class="box__item">
                                <div class="ui-table-container">
                                    <div class="ui-table-toolbar">
                                        <a href="/school/route/statistics/lightsOutRankingMore" class="ui-button ui-button-sm fn-right" title="查看全部"><i class="fa fa-ellipsis-v"></i>&nbsp;查看全部</a>
                                        <h5 class="toolbar__title">昨日最晚熄灯</h5>
                                    </div>
                                    <table class="ui-table" id="lightout_ranking">
                                        <thead>
                                            <tr>
                                                <th style="width:30px;">排名</th>
                                                <th>寝室信息</th>
                                                <th>熄灯时间</th>
                                            </tr>
                                        </thead>
                                        <tbody></tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="box__item">
                                <div class="ui-table-container">
                                    <div class="ui-table-toolbar">
                                        <a href="/school/route/statistics/ElectricRankingMore" class="ui-button ui-button-sm fn-right" title="更多历史记录"><i class="fa fa-ellipsis-v"></i>&nbsp;更多历史记录</a>
                                        <h5 class="toolbar__title">昨日用电排名</h5>
                                    </div>
                                    <table class="ui-table" id="electric_ranking">
                                        <thead>
                                            <tr>
                                                <th style="width:30px;">排名</th>
                                                <th>房间名称</th>
                                                <th>用电数额</th>
                                            </tr>
                                        </thead>
                                        <tbody></tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <!--// .dashboard-table-box -->

                        <div class="dashboard-charts">
                            <div class="charts__item">
                                <div class="chart-box">
                                    <h5 class="chart-title">数据表格(demo)</h5>
                                    <div class="chart-content"><div id="J_highcharts_content_1"></div></div>
                                </div>
                            </div>
                            <div class="charts__item">
                                <div class="chart-box">
                                    <h5 class="chart-title">数据表格(demo)</h5>
                                    <div class="chart-content"><div id="J_highcharts_content_2"></div></div>
                                </div>
                            </div>
                        </div>
                        <!--//.  -->
                    </div>
                    <!--// .panel__body -->
                </div>
                <!--// .ui-panel -->


                <div class="ui-panel_danger">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-bullhorn"></i>&nbsp;智能告警通知</span>
                    </div>
                    <div class="panel__body">
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="/school/route/alam/list" class="ui-button ui-button-sm fn-right" title="查看全部"><i class="fa fa-ellipsis-v"></i>&nbsp;查看全部</a>
                                <a href="javascript:void(0);" class="ui-button ui-button-sm fn-right" title="刷新" id="refresh_alam_message"><i class="fa fa-refresh"></i>&nbsp;刷新</a>
                                <h5 class="toolbar__title">未处理告警</h5>
                            </div>
                            <table class="ui-table" id="alam_message">
                                <thead>
                                    <tr>
                                        <th style="width: 30px;">序号</th>
                                        <th>所属楼宇</th>
                                        <th>所属楼层</th>
                                        <th>所属房间</th>
                                        <th>节点MAC</th>
                                        <th>告警信息</th>
                                        <th style="width: 65px;">告警时间</th>
                                        <th>处理备注</th>
                                        <th style="width: 100px;">操作</th>
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
    SidebarMenu.init('dashboard');
});


var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js');

var Overview_list = (function(){
    var $container = null,
        $content = null;

    var data = null;

    var get_resources_handler = null;
    function get_resources(_success_callback){
        if(get_resources_handler!==null){
            return false;
        }

        render_loading();

        get_resources_handler = $.getJSON('/school/V1/indexPage/_overview',{
            limit: 5
        }).done(function(_data, _status, _xhr){
            if(parseInt(_data['code'], 10)===0){
                data = _data;
                render_data(_data['dataObject']);

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
        var tpl = [];
        $.each(_result, function(__index, __item){
            tpl.push([
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'">',
                    '<td>'+ (__index+1) +'</td>',
                    '<td>'+ __item['buildingName'] +'</td>',
                    '<td>'+ __item['buildingLevelName'] +'</td>',
                    '<td>'+ __item['rooms'] +'</td>',
                    '<td>'+ __item['lights'] +'</td>',
                    '<td>'+ __item['fan'] +'</td>',
                    '<td>'+ __item['socket'] +'</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }

    return {
        init: function(_$table_id){
            $container = $('#'+_$table_id);
            $content = $container.children('tbody').eq(0);

            get_resources(function(_data){
                // TODO
            });

            $content.on('click.edit', 'a.J_btn_reload', function(){
                get_resources();
            });

            // 绑定刷新事件
            $('#refresh_overview_list').on('click.overview', function(){
                get_resources();
            });
        }
    };
})();
Overview_list.init('overview_list');


var Lightout_ranking = (function(){
    var $container = null,
        $content = null;

    var data = null;

    var get_resources_handler = null;
    function get_resources(_success_callback){
        if(get_resources_handler!==null){
            return false;
        }

        render_loading();
        // 获取前一天的date
        var yesterday = (function(d){ d.setDate(d.getDate()-1); return d})(new Date);

        get_resources_handler = $.getJSON('/school/V1/indexPage/_lightsOutRanking', {
            date: (yesterday.getFullYear() + '-' + (yesterday.getMonth()+1) + '-' + yesterday.getDate()),
            limit: 5
        }).done(function(_data, _status, _xhr){
            if(parseInt(_data['code'], 10)===0){
                data = _data;
                render_data(_data['dataObject']);

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
        if(_result.length<5){
            var loop = 5 - _result.length;
            for(;loop>0;loop--){
                _result.push({
                    'roomName': '&nbsp;',
                    'date': '&nbsp;',
                    'outTume': '&nbsp;'
                })
            }
        }
        var tpl = [];
        $.each(_result, function(__index, __item){
            tpl.push([
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'">',
                    '<td>'+ (__index+1) +'</td>',
                    '<td>'+ __item['roomName'] +'</td>',
                    '<td>'+ $.trim(__item['outTume'].replace(__item['date'], '')) +'</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }

    return {
        init: function(_$table_id){
            $container = $('#'+_$table_id);
            $content = $container.children('tbody').eq(0);

            get_resources(function(_data){
                // TODO
            });

            $content.on('click.edit', 'a.J_btn_reload', function(){
                get_resources();
            });
        }
    };
})();
Lightout_ranking.init('lightout_ranking');

var Electric_ranking = (function(){
    var $container = null,
        $content = null;

    var data = null;

    var get_resources_handler = null;
    function get_resources(_success_callback){
        if(get_resources_handler!==null){
            return false;
        }

        render_loading();
        // 获取前一天的date
        var yesterday = (function(d){ d.setDate(d.getDate()-1); return d})(new Date);

        get_resources_handler = $.getJSON('/school/V1/indexPage/_ElectricRanking', {
            date: (yesterday.getFullYear() + '-' + (yesterday.getMonth()+1) + '-' + yesterday.getDate()),
            type: '1',
            limit: 5
        }).done(function(_data, _status, _xhr){
            if(parseInt(_data['code'], 10)===0){
                data = _data;
                render_data(_data['dataObject']);

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
        if(_result.length<5){
            var loop = 5 - _result.length;
            for(;loop>0;loop--){
                _result.push({
                    'roomName': '&nbsp;',
                    'point': '&nbsp;'
                })
            }
        }
        var tpl = [];
        $.each(_result, function(__index, __item){
            tpl.push([
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'">',
                    '<td>'+ (__index+1) +'</td>',
                    '<td>'+ __item['roomName'] +'</td>',
                    '<td>'+ __item['point'] +'</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }

    return {
        init: function(_$table_id){
            $container = $('#'+_$table_id);
            $content = $container.children('tbody').eq(0);

            get_resources(function(_data){
                // TODO
            });

            $content.on('click.edit', 'a.J_btn_reload', function(){
                get_resources();
            });
        }
    };
})();
Electric_ranking.init('electric_ranking');


var Alam_message = (function(){
    var page_no = 1,
        page_limit = 5,
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

        render_loading();

        var page_next = _page_next || page_no;
        page_next = (page_next<=0) ? 1 : ((page_total===null) || (page_next<=page_total)) ? page_next : page_total;
        page_no = page_next;

        get_resources_handler = $.getJSON('/school/V1/AlamService/_findAlamPage', {
            pageNo: page_next,
            pageSize: page_limit,
            alam_status: 0
        }).done(function(_data, _status, _xhr){
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
    function render_data(_result, _offset_base){
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="alam_item_'+ __item['record_no'] +'">',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td>'+ __item['building_name'] +'</td>',
                    '<td>'+ __item['level_name'] +'</td>',
                    '<td>'+ __item['room_name'] +'</td>',
                    '<td>'+ __item['node_mac'] +'</td>',
                    '<td>'+ __item['alam_info'] +'</td>',
                    '<td>'+ __item['alam_time'] +'</td>',
                    '<td class="J_item_handle_info">'+ (__item['handle_info'] || '&nbsp;') +'</td>',
                    '<td class="J_item_console">',
                        ((parseInt(__item['alam_status'], 10)===1) ? '<span class="ui-text-success">已处理</span>' : '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="立即处理" data-record-no="'+ __item['record_no'] +'"><i class="fa fa-edit"></i>&nbsp;立即处理</a>'),
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }

    function update_item(_alam_no, _data){
        var $item = $('#alam_item_'+_alam_no);
        if($item.length){
            $item.find('td.J_item_handle_info').eq(0).html(_data['handle_info']);
            $item.find('td.J_item_console').eq(0).html('<span class="ui-text-success">已处理</span>');

            // update data
            find_by_no(_alam_no, function(_index){
                $.each(_data, function(_key, _val){
                    (data['result'][_index][_key]!==undefined) && (data['result'][_index][_key] = _val);
                });
            })
        }
    }

    return {
        init: function(_$table_id){
            $container = $('#'+_$table_id);
            $content = $container.children('tbody').eq(0);

            get_resources();

            $content.on('click.edit', 'a.J_btn_reply', function(){
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
                                        autofocus: true
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

            $content.on('click.edit', 'a.J_btn_reload', function(){
                get_resources();
            });

            // 绑定刷新事件
            $('#refresh_alam_message').on('click.overview', function(){
                get_resources();
            });
        }
    };
})();
Alam_message.init('alam_message');


require.async(['assets/vendors/highcharts/highcharts.js'], function(){
    // console.log(Highcharts)
})

</script>

</body>
</html>
