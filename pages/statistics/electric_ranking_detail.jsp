<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>综合报表-班级能耗排名报表-报表明细</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="statistics.scss" charset="utf-8">

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
                <span class="breadcrumb-active">综合报表</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">班级能耗排名报表</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">报表明细</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <a href="javascript:void(0);" class="ui-button ui-button-sm fn-right" title="返回" id="back_to_list"><i class="fa fa-undo"></i>&nbsp;返回</a>
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;班级能耗报表明细</span>
                    </div>
                    <div class="panel__body">
                        <div class="ui-table-container">
                            <table class="ui-table" id="electric_ranking">
                                <thead>
                                    <tr>
                                        <th style="width:46px;">序号</th>
                                        <th style="width:180px">能耗值（KW）</th>
                                        <th>开始能耗值</th>
                                        <th>结束能耗值</th>
                                        <th>寝室</th>
                                    </tr>
                                </thead><!-- 表头可选 -->
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="electric_ranking_paging"></div>
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
    SidebarMenu.init('statistics', 'electric');
});

var Url = require('url'),
    Paging = require('/components/paging/paging.js');

var Electric_ranking_detail = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var get_resources_handler = null;
    function get_resources(_page_next, _class_no, _success_callback){
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

        resource_params['class_no'] = _class_no;

        get_resources_handler = $.getJSON('/school/V1/report/_energyViewPage', resource_params).done(function(_data, _status, _xhr){
            if(parseInt(_data['code'], 10)===0){
                page_no = _data['pageNo'];
                page_limit = _data['pageSize'];
                page_total = _data['totalPages'];
                records_length = _data['records'];

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
                '<td colspan="5">',
                    '<div class="cell__placeholder">',
                        '<i class="fa fa-spinner fa-spin"></i>&nbsp;数据加载中...',
                    '</div>',
                '</td>'
            ].join(''));
        }
    }
    function render_error(){
        $content.html([
            '<td colspan="5">',
                '<div class="cell__placeholder error">',
                    '<i class="fa fa-info-circle"></i>&nbsp;数据加载失败，<a href="javascript:void(0);" class="placeholder-link J_btn_reload">请再试一次</a>！',
                '</div>',
            '</td>'
        ].join(''));
    }
    function render_data(_result, _offset_base){
        if(_result===undefined || _result.length===0){
            $content.html([
                '<td colspan="5">',
                    '<div class="cell__placeholder">',
                        '<i class="fa fa-info-circle"></i>&nbsp;暂时没有数据',
                    '</div>',
                '</td>'
            ].join(''));
            return;
        }
        var tpl = [],
            offset_base = _offset_base || 0;
        $.each(_result, function(__index, __item){
            tpl.push([
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'">',
                    '<td>'+ (__index+1) +'</td>',
                    '<td>'+ __item['duration'] +'</td>',
                    '<td>'+ __item['begin_power'] +'</td>',
                    '<td>'+ __item['end_power'] +'</td>',
                    '<td>'+ __item['building_name'] + '&nbsp;' + __item['level_name'] + '&nbsp;' + __item['room_name'] +'</td>',
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

            get_resources(page_no, _params['class_no'], function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('electric_ranking_paging', {
                    pageNo:  _data['pageNo'],
                    totalPages: _data['totalPages'],
                    pageSize: _data['pageSize'],
                    records: _data['records']
                })
            });

            $content.on('click.edit', 'a.J_btn_reload', function(){
                window.location.reload();
            });
        }
    };
})();

Electric_ranking_detail.init('electric_ranking', {
    'page_no': Url('?pageNo') || 1,
    'page_limit': Url('?pageSize') || 10,
    'class_no': Url('?class_no')
});

$('#back_to_list').on('click', function(){
    var list_path = Url('?list_path') || null,
        history_back_url = (list_path!==null && list_path.length!==0) ? window.decodeURIComponent(list_path) : '/school/route/statistics/ElectricRankingMore';
    window.location.href = history_back_url;
})
</script>

</body>
</html>
