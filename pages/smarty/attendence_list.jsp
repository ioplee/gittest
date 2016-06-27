<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能考勤</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="./smarty.scss" charset="utf-8">

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
                <span class="breadcrumb-active">评分考勤</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;考勤统计</span>
                    </div>
                    <div class="panel__body">
                        <div class="panel-toolbar">
                            <div class="ui-search">
                                <label for="" class="search-label">快速检索：</label>
                                <div class="search__item">
                                    <select name="" id="search_select_building" class="ui-form-select">
                                        <option value="0">请选择楼宇</option>
                                    </select>
                                </div>
                                <div class="search__item">
                                    <select name="" id="search_select_level" class="ui-form-select">
                                        <option value="0">请选择楼层</option>
                                    </select>
                                </div>
                                <div class="search__item">
                                    <select name="" id="search_select_room" class="ui-form-select">
                                        <option value="0">请选择房间</option>
                                    </select>
                                </div>
                                <a href="javascript:void(0);" class="ui-button ui-button-sm" id="search_submit"><i class="fa fa-search"></i>&nbsp;检索</a>
                            </div>
                            <div class="panel-toolbar-subtab fn-right" id="attendance_type_tabs">
                                时间范围：<a href="/school/route/attendence/list?attendance_type=yesterday" class="subtab__item" data-attendance-type="yesterday">昨日考勤</a>&nbsp;&#124;&nbsp;<a href="/school/route/attendence/list?attendance_type=week" class="subtab__item" data-attendance-type="week">七日考勤</a>&nbsp;&#124;&nbsp;<a href="/school/route/attendence/list?attendance_type=month" class="subtab__item" data-attendance-type="month">月度考勤</a>
                            </div>
                        </div>
                        <div class="ui-table-container">
                            <table class="ui-table" id="attendence_list">
                                <thead>
                                    <tr>
                                        <th style="width:30px">序号</th>
                                        <th>所属楼宇</th>
                                        <th>所属楼层</th>
                                        <th>所属房间</th>
                                        <th>所属床位</th>
                                        <th>所属班级</th>
                                        <th>学生姓名</th>
                                        <th>班主任</th>
                                        <th>未出勤(天)</th>
                                        <th>总出勤(天)</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="attendence_list_paging"></div>
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
    SidebarMenu.init('smarty', 'list');
});


var Url = require('url'),
    Paging = require('/components/paging/paging.js'),
    SelectDict = require('/components/select-option/service.js');

var SEARCH_BUILDING_NO = Url('?building_no') || null,
    SEARCH_BUILDING_LEVEL_NO = Url('?level_no') || null,
    SEARCH_ROOM_NO = Url('?room_no') || null;

var ATTENDANCE_TYPE = Url('?attendance_type') || 'yesterday',
    ATTENDANCE_REMOTE_PATH = {
        'yesterday': '/school/V1/attendance/_findAttendanceYesterday',
        'week': '/school/V1/attendance/_findAttendanceWeek',
        'month': '/school/V1/attendance/_findAttendanceMonth'
    }[ATTENDANCE_TYPE],
    ATTENDANCE_COUNT = {
        'yesterday': 1,
        'week': 5,
        'month': 22
    }[ATTENDANCE_TYPE];

$('#attendance_type_tabs').find('a.subtab__item').each(function(){
    if($(this).data('attendance-type')==ATTENDANCE_TYPE){
        $(this).addClass('actived');
    }
});

var Attendence_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var get_resources_handler = null;
    function get_resources(_page_next, _building_no, _building_level_no, _room_no, _success_callback){
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
        if(_building_no!==null){
            resource_params['building_no'] = _building_no;
        }
        if(_building_level_no!==null){
            resource_params['buildingLevel_no'] = _building_level_no;
        }
        if(_room_no!==null){
            resource_params['room_no'] = _room_no;
        }

        get_resources_handler = $.getJSON(ATTENDANCE_REMOTE_PATH, resource_params).done(function(_data, _status, _xhr){
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'">',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td>'+ __item['buildingName'] +'</td>',
                    '<td>'+ __item['levelName'] +'</td>',
                    '<td>'+ __item['roomName'] +'</td>',
                    '<td>'+ __item['bedName'] +'</td>',
                    '<td>'+ __item['className'] +'</td>',
                    '<td>'+ __item['studentName'] +'</td>',
                    '<td>'+ __item['teacherName'] +'</td>',
                    '<td>'+ ((ATTENDANCE_TYPE==='yesterday')?((__item['NOCount']=='0')?'1':'0'):(__item['NOCount']||0)) +'</td>',
                    '<td>'+ ATTENDANCE_COUNT +'</td>',
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

            get_resources(page_no, _params['building_no'], _params['building_level_no'], _params['room_no'], function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('attendence_list_paging', {
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

Attendence_list.init('attendence_list', {
    'page_no': Url('?pageNo') || 1,
    'page_limit': Url('?pageSize') || 10,
    'building_no': SEARCH_BUILDING_NO,
    'building_level_no': SEARCH_BUILDING_LEVEL_NO,
    'room_no': SEARCH_ROOM_NO
});

var $search_select_building = $('#search_select_building'),
    $search_select_level = $('#search_select_level'),
    $search_select_room = $('#search_select_room');
SelectDict.get({
    bizType: 'building'
}, function(_data){
    var options = [];
    $.each(_data, function(_i, _building_option){
        options.push('<option value="'+ _building_option['building_no'] +'">'+ _building_option['building_name'] +'</option>')
    });
    $search_select_building.append(options.join(''));

    // init search select
    if(SEARCH_BUILDING_NO!==null){

        $search_select_building.val(SEARCH_BUILDING_NO);

        SelectDict.get({
            bizType: 'buildingLevel',
            no: SEARCH_BUILDING_NO
        }, function(_data){
            var options = ['<option value="0">请选择楼层</option>'];
            $.each(_data, function(_i, _building_level_option){
                options.push('<option value="'+ _building_level_option['level_no'] +'">'+ _building_level_option['level_name'] +'</option>')
            });
            $search_select_level.html(options.join(''));

            // init search select
            if(SEARCH_BUILDING_LEVEL_NO!==null){

                $search_select_level.val(SEARCH_BUILDING_LEVEL_NO);

                SelectDict.get({
                    bizType: 'room',
                    no: SEARCH_BUILDING_LEVEL_NO
                }, function(_data){
                    var options = ['<option value="0">请选择房间</option>'];
                    $.each(_data, function(_i, _room_option){
                        options.push('<option value="'+ _room_option['room_no'] +'">'+ _room_option['room_name'] +'</option>')
                    });
                    $search_select_room.html(options.join('')).val(SEARCH_ROOM_NO || 0);
                });
            }
        });
    }
});

$search_select_building.on('change', function(){
    var building_no = $(this).val(),
        options = ['<option value="0">请选择楼层</option>'];
    if(parseInt(building_no, 10)===0){
        $search_select_level.html(options.join('')).val(0);
    }else{
        SelectDict.get({
            bizType: 'buildingLevel',
            no: building_no
        }, function(_data){
            $.each(_data, function(_i, _building_level_option){
                options.push('<option value="'+ _building_level_option['level_no'] +'">'+ _building_level_option['level_name'] +'</option>')
            });
            $search_select_level.html(options.join('')).val(0);
        });
    }
});

$search_select_level.on('change', function(){
    var building_level_no = $(this).val(),
        options = ['<option value="0">请选择房间</option>'];
    if(parseInt(building_level_no, 10)===0){
        $search_select_room.html(options.join('')).val(0);
    }else{
        SelectDict.get({
            bizType: 'room',
            no: building_level_no
        }, function(_data){
            $.each(_data, function(_i, _room_option){
                options.push('<option value="'+ _room_option['room_no'] +'">'+ _room_option['room_name'] +'</option>')
            });
            $search_select_room.html(options.join('')).val(0);
        });
    }
});

$('#search_submit').on('click', function(){
    var building_no = parseInt($search_select_building.val(), 10),
        building_level_no = parseInt($search_select_level.val(), 10),
        room_no = parseInt($search_select_room.val(), 10),
        search_url = Url('path') + '?attendance_type=' + ATTENDANCE_TYPE;

    if(building_no!==0){
        search_url += '&building_no=' + building_no;

        if(building_level_no!==0){
            search_url += '&level_no=' + building_level_no;

            if(room_no!==0){
                search_url += '&room_no=' + room_no;
            }
        }
    }

    window.location.href = search_url;
});
</script>

</body>
</html>
