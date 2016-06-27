<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>综合报表-班级考勤报表</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="statistics.scss" charset="utf-8">
    <link rel="stylesheet" href="/assets/vendors/bootstrap/dist/css/bootstrap.css" charset="utf-8">
    <link rel="stylesheet" href="assets/vendors/bootstrap-datepicker/dist/css/bootstrap-datepicker3.css" charset="utf-8">

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
                <span class="breadcrumb-active">班级考勤报表</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;班级考勤报表</span>
                    </div>
                    <div class="panel__body">
                        <div class="panel-toolbar">
                            <div class="ui-search">
                                <label for="" class="search-label">时间范围：</label>
                                <span id="search_daterange" class="search__item input-daterange">
                                    <input type="text" class="ui-input search-date" id="search_date_start" placeholder="起始时间" name="start">
                                    至
                                    <input type="text" class="ui-input search-date" id="search_date_end" placeholder="结束时间" name="end">
                                </span>
                                <label for="" class="search-label">班级名称：</label>
                                <div class="search__item">
                                    <input type="text" class="ui-input" id="search_class_name" placeholder="班级名称">
                                </div>
                                <a href="javascript:void(0);" class="ui-button ui-button-sm search__item_last" id="search_submit"><i class="fa fa-search"></i>&nbsp;检索</a>
                            </div>
                        </div>
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="导出"><i class="fa fa-file-excel-o"></i>&nbsp;导出</a>
                            </div>
                            <table class="ui-table" id="attendence_ranking">
                                <thead>
                                    <tr>
                                        <th style="width:46px;">排名</th>
                                        <th>班级</th>
                                        <th>老师</th>
                                        <th style="width:180px">缺勤人数</th>
                                        <th style="width:120px">操作</th>
                                    </tr>
                                </thead><!-- 表头可选 -->
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="attendence_ranking_paging"></div>
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
    SidebarMenu.init('statistics', 'attendence');
});

var Url = require('url'),
    Paging = require('/components/paging/paging.js'),
    Datepicker = require('datepicker');

var Attendence_ranking = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var get_resources_handler = null;
    function get_resources(_page_next, _begin_date, _end_date, _class_name, _success_callback){
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

        if(_begin_date!==null && _begin_date!==undefined && _begin_date.length>0 && /^\d{4}-\d{1,2}-\d{1,2}/.test(_begin_date)){
            resource_params['beginDate'] = beginDate;
        }
        if(_end_date!==null && _end_date!==undefined && _end_date.length>0 && /^\d{4}-\d{1,2}-\d{1,2}/.test(_end_date)){
            resource_params['endDate'] = endDate;
        }
        if(_class_name!==null && _class_name!==undefined && _class_name.length){
            resource_params['class_name'] = _class_name;
        }

        get_resources_handler = $.getJSON('/school/V1/report/_attendancePage', resource_params).done(function(_data, _status, _xhr){
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
                    '<td>'+ __item['class_name'] +'</td>',
                    '<td>'+ __item['teacher_name'] +'</td>',
                    '<td>'+ __item['count'] +'</td>',
                    '<td>',
                        '<a href="/school/route/statistics/attendenceRankingMoreDetail?class_no='+ __item['class_no'] +'&list_path='+ window.encodeURIComponent(Url())+'" class="ui-button ui-button-xs" title="查看明细"><i class="fa fa-th"></i>&nbsp;查看明细</a>',
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

            get_resources(page_no, _params['begin_date'], _params['end_date'], _params['class_name'], function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('attendence_ranking_paging', {
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

Attendence_ranking.init('attendence_ranking', {
    'page_no': Url('?pageNo') || 1,
    'page_limit': Url('?pageSize') || 10,
    'begin_date': Url('?beginDate') || 1,
    'end_date': Url('?endDate') || 1,
    'class_name': Url('?class_name')
});


var $search_date_start = $('#search_date_start'),
    $search_date_end = $('#search_date_end'),
    $search_class_name = $('#search_class_name');

$('#search_daterange').datepicker({
    endDate: '0d',
    format: 'yyyy-mm-dd',
    autoclose: true,
    todayHighlight: true
}).on('changeDate', function(){
    // console.log(this.value)
});

$search_class_name.val(Url('?class_name'));

$('#search_submit').on('click', function(){
    var beginDate = $.trim($search_date_start.val()),
        endDate = $.trim($search_date_end.val()),
        class_name = $.trim($search_class_name.val());

    var search_url = Url('path');

    var params = {};

    if(class_name.length){
        params['class_name'] = class_name;
    }
    if(beginDate.length>0 && /^\d{4}-\d{1,2}-\d{1,2}/.test(beginDate)){
        params['beginDate'] = beginDate.replace(/-/gi, '');
    }
    if(endDate.length>0 && /^\d{4}-\d{1,2}-\d{1,2}/.test(endDate)){
        params['endDate'] = endDate.replace(/-/gi, '');
    }

    window.location.href = search_url + '?' + $.param(params);
});
</script>

</body>
</html>
