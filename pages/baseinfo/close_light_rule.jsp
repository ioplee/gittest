<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能控制-基础配置-熄灯规则</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="./baseinfo.scss" charset="utf-8">

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
                <span class="breadcrumb-active">基础配置</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">熄灯规则</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;熄灯规则列表</span>
                    </div>
                    <div class="panel__body">
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="新增" id="rule_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                            </div>
                            <table class="ui-table" id="rule_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width: 30px;">序号</th>
                                        <th>规则名称</th>
                                        <th>规则时间</th>
                                        <th style="width: 80px;">规则状态</th>
                                        <th style="width: 80px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="rule_list_paging"></div>
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
    SidebarMenu.init('baseinfo', 'lights');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js');

var Rule_list = (function(){
    var page_no = 1,
        page_limit = 10,
        page_total = null,
        records_length = null;

    var $container = null,
        $content = null;

    var data = null;

    function find_by_no(_rule_id, _callback){
        var item = null;

        $.each(data['result'], function(__index, __item){
            if(__item['rule_id']==_rule_id){
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

        get_resources_handler = $.getJSON('/school/biz/clrule/_findPage', {
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
                '<td colspan="6">',
                    '<div class="cell__placeholder">',
                        '<i class="fa fa-spinner fa-spin"></i>&nbsp;数据加载中...',
                    '</div>',
                '</td>'
            ].join(''));
        }
    }
    function render_error(){
        $content.html([
            '<td colspan="6">',
                '<div class="cell__placeholder error">',
                    '<i class="fa fa-info-circle"></i>&nbsp;数据加载失败，<a href="javascript:void(0);" class="placeholder-link J_btn_reload">请再试一次</a>！',
                '</div>',
            '</td>'
        ].join(''));
    }
    function render_data(_result, _offset_base){
        if(_result===undefined || _result.length===0){
            $content.html([
                '<td colspan="6">',
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
                '<tr class="'+ ((__index>0 && (__index%2)) ? 'ui-table-split' : '') +'" id="rule_item_'+ __item['rule_id'] +'">',
                    '<td><input type="checkbox" class="J_select_one" data-rule-id="'+ __item['rule_id'] +'"></td>',
                    '<td>'+ (_offset_base + (__index+1)) +'</td>',
                    '<td class="J_item_name">'+ __item['rule_name'] +'</td>',
                    '<td class="J_item_value">'+ __item['rule_value'] +'</td>',
                    '<td class="J_item_status">'+ ((parseInt(__item['rule_status'], 10)===0) ? '有效' : '无效') +'</td>',
                    '<td>',
                        '<a href="javascript:void(0);" class="ui-button ui-button-xs J_btn_edit" title="编辑" data-rule-id="'+ __item['rule_id'] +'"><i class="fa fa-edit"></i>&nbsp;编辑</a>',
                    '</td>',
                '</tr>',
            ].join(''));
        });
        $content.html(tpl.join(''))
    }
    function update_item(_rule_id, _data){
        var $item = $('#rule_item_'+_rule_id);
        if($item.length){
            $item.find('td.J_item_name').eq(0).html(_data['rule_name']);
            $item.find('td.J_item_value').eq(0).html(_data['rule_value']);
            $item.find('td.J_item_status').eq(0).html((parseInt(_data['rule_status'], 10)===0) ? '有效' : '无效');

            // update data
            find_by_no(_rule_id, function(_index){
                data['result'][_index]['rule_name'] = _data['rule_name'];
                data['result'][_index]['rule_value'] = _data['rule_value'];
                data['result'][_index]['rule_status'] = _data['rule_status'];
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
            page_no = _params['page_no'];
            page_limit = _params['page_limit'];

            get_resources(page_no, function(_data){
                (!!_data['result'] && _data['result'].length>0) && Paging.init('rule_list_paging', {
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
                var item_data = find_by_no($(this).data('rule-id'));

                var $rule_name = null,
                    $rule_value_h = null,
                    $rule_value_m = null,
                    $rule_value_s = null,
                    $rule_status = null;

                var edit_handler = null;
                function check(){
                    return ($.trim($rule_name.val()).length !== 0);
                }

                function get_rule_time(){
                    return $rule_value_h.val() + ':' + $rule_value_m.val() + ':' + $rule_value_s.val();
                }


                ArtDialog({
                    'skin': 'dialog-form',
                    'modal': true,
                    'title': '编辑熄灯规则',
                    'content': [
                        '<div class="">',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*规则编号:</label>',
                                '<span class="group__text">'+ item_data['rule_id'] +'</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*规则名称:</label>',
                                '<input type="text" class="ui-input group__control J_dialog_rule_name" value="'+ item_data['rule_name'] +'">',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">*规则时间:</label>',
                                '<div class="group__control datepick-select">',
                                    '<select name="" class="ui-select group__control J_dialog_rule_value_h">',
                                        '<option value="01">01</option><option value="02">02</option><option value="03">03</option><option value="04">04</option><option value="05">05</option><option value="06">06</option><option value="07">07</option><option value="08">08</option><option value="09">09</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option>',
                                    '</select>',
                                    '&nbsp;时&nbsp;&nbsp;',
                                    '<select name="" class="ui-select group__control J_dialog_rule_value_m">',
                                        '<option value="00">00</option><option value="01">01</option><option value="02">02</option><option value="03">03</option><option value="04">04</option><option value="05">05</option><option value="06">06</option><option value="07">07</option><option value="08">08</option><option value="09">09</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option><option value="32">32</option><option value="33">33</option><option value="34">34</option><option value="35">35</option><option value="36">36</option><option value="37">37</option><option value="38">38</option><option value="39">39</option><option value="40">40</option><option value="41">41</option><option value="42">42</option><option value="43">43</option><option value="44">44</option><option value="45">45</option><option value="46">46</option><option value="47">47</option><option value="48">48</option><option value="49">49</option><option value="50">50</option><option value="51">51</option><option value="52">52</option><option value="53">53</option><option value="54">54</option><option value="55">55</option><option value="56">56</option><option value="57">57</option><option value="58">58</option><option value="59">59</option>',
                                    '</select>',
                                    '&nbsp;分&nbsp;&nbsp;',
                                    '<select name="" class="ui-select group__control J_dialog_rule_value_s">',
                                        ,
                                        '<option value="00">00</option><option value="01">01</option><option value="02">02</option><option value="03">03</option><option value="04">04</option><option value="05">05</option><option value="06">06</option><option value="07">07</option><option value="08">08</option><option value="09">09</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option><option value="32">32</option><option value="33">33</option><option value="34">34</option><option value="35">35</option><option value="36">36</option><option value="37">37</option><option value="38">38</option><option value="39">39</option><option value="40">40</option><option value="41">41</option><option value="42">42</option><option value="43">43</option><option value="44">44</option><option value="45">45</option><option value="46">46</option><option value="47">47</option><option value="48">48</option><option value="49">49</option><option value="50">50</option><option value="51">51</option><option value="52">52</option><option value="53">53</option><option value="54">54</option><option value="55">55</option><option value="56">56</option><option value="57">57</option><option value="58">58</option><option value="59">59</option>',
                                    '</select>',
                                    '&nbsp;秒',
                                '</div>',
                            '</div>',
                            '<div class="form-group">',
                                '<label for="" class="group__label">规则状态:</label>',
                                '<select class="ui-select group__control J_dialog_rule_status">',
                                    '<option value="0">有效</option>',
                                    '<option value="1">无效</option>',
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
                            ruleName: $rule_name.val(),
                            ruleValue: get_rule_time(),
                            ruleStatus: $rule_status.val(),
                            ruleId: item_data['rule_id']
                        };

                        edit_handler = $.post('/school/biz/clrule/_modifyData', update_params).done(function(_data, _status, _xhr){
                            if(parseInt(_data['code'], 10)===0 && _data['success']==true){

                                update_item(item_data['rule_id'], {
                                    rule_name: update_params['ruleName'],
                                    rule_value: update_params['ruleValue'],
                                    rule_status: update_params['ruleStatus']
                                });

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
                                dialog.title('编辑熄灯规则');
                                dialog.statusbar([
                                    '<div class="dialog-form-tip danger">',
                                        '<i class="fa fa-info-circle"></i>&nbsp;',
                                        _data['msg'],
                                    '</div>'
                                ].join(''));
                            }
                        }).fail(function(_xhr, _status, _error) {
                            dialog.title('编辑熄灯规则');
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
                        $rule_name = $(this.node).find('input.J_dialog_rule_name').eq(0);
                        $rule_value_h = $(this.node).find('select.J_dialog_rule_value_h').eq(0);
                        $rule_value_m = $(this.node).find('select.J_dialog_rule_value_m').eq(0);
                        $rule_value_s = $(this.node).find('select.J_dialog_rule_value_s').eq(0);
                        $rule_status = $(this.node).find('select.J_dialog_rule_status').eq(0);


                        $.each(item_data['rule_value'].split(':'), function(_i, _m){
                            switch(_i){
                                case 0:
                                    $rule_value_h.val(_m);
                                    break;
                                case 1:
                                    $rule_value_m.val(_m);
                                    break;
                                case 2:
                                    $rule_value_s.val(_m);
                                    break;
                            }
                        });

                        $rule_status.val(item_data['rule_status']);
                        $rule_name.on('change focus', function(){
                            dialog.statusbar(null);
                        })
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
        }
    };
})();

Rule_list.init('rule_list', {
    page_no: Url('?pageNo') || 1,
    page_limit: Url('?pageSize') || 10
});

// 绑定新增事件
$('#rule_add').on('click.add', function(){
    var $rule_name = null,
        $rule_value_h = null,
        $rule_value_m = null,
        $rule_value_s = null,
        $rule_status = null;

    var add_handler = null;
    function check(){
        return ($.trim($rule_name.val()).length !== 0);
    }

    function get_rule_time(){
        return $rule_value_h.val() + ':' + $rule_value_m.val() + ':' + $rule_value_s.val();
    }


    ArtDialog({
        'skin': 'dialog-form',
        'modal': true,
        'title': '新增熄灯规则',
        'content': [
            '<div class="">',
                '<div class="form-group">',
                    '<label for="" class="group__label">*规则名称:</label>',
                    '<input type="text" class="ui-input group__control J_dialog_rule_name" value="">',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">*规则时间:</label>',
                    '<div class="group__control datepick-select">',
                        '<select name="" class="ui-select group__control J_dialog_rule_value_h">',
                            '<option value="01">01</option><option value="02">02</option><option value="03">03</option><option value="04">04</option><option value="05">05</option><option value="06">06</option><option value="07">07</option><option value="08">08</option><option value="09">09</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option>',
                        '</select>',
                        '&nbsp;时&nbsp;&nbsp;',
                        '<select name="" class="ui-select group__control J_dialog_rule_value_m">',
                            '<option value="00">00</option><option value="01">01</option><option value="02">02</option><option value="03">03</option><option value="04">04</option><option value="05">05</option><option value="06">06</option><option value="07">07</option><option value="08">08</option><option value="09">09</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option><option value="32">32</option><option value="33">33</option><option value="34">34</option><option value="35">35</option><option value="36">36</option><option value="37">37</option><option value="38">38</option><option value="39">39</option><option value="40">40</option><option value="41">41</option><option value="42">42</option><option value="43">43</option><option value="44">44</option><option value="45">45</option><option value="46">46</option><option value="47">47</option><option value="48">48</option><option value="49">49</option><option value="50">50</option><option value="51">51</option><option value="52">52</option><option value="53">53</option><option value="54">54</option><option value="55">55</option><option value="56">56</option><option value="57">57</option><option value="58">58</option><option value="59">59</option>',
                        '</select>',
                        '&nbsp;分&nbsp;&nbsp;',
                        '<select name="" class="ui-select group__control J_dialog_rule_value_s">',
                            ,
                            '<option value="00">00</option><option value="01">01</option><option value="02">02</option><option value="03">03</option><option value="04">04</option><option value="05">05</option><option value="06">06</option><option value="07">07</option><option value="08">08</option><option value="09">09</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option><option value="32">32</option><option value="33">33</option><option value="34">34</option><option value="35">35</option><option value="36">36</option><option value="37">37</option><option value="38">38</option><option value="39">39</option><option value="40">40</option><option value="41">41</option><option value="42">42</option><option value="43">43</option><option value="44">44</option><option value="45">45</option><option value="46">46</option><option value="47">47</option><option value="48">48</option><option value="49">49</option><option value="50">50</option><option value="51">51</option><option value="52">52</option><option value="53">53</option><option value="54">54</option><option value="55">55</option><option value="56">56</option><option value="57">57</option><option value="58">58</option><option value="59">59</option>',
                        '</select>',
                        '&nbsp;秒',
                    '</div>',
                '</div>',
                '<div class="form-group">',
                    '<label for="" class="group__label">规则状态:</label>',
                    '<select class="ui-select group__control J_dialog_rule_status">',
                        '<option value="0">有效</option>',
                        '<option value="1">无效</option>',
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
            var update_params = {
                ruleName: $rule_name.val(),
                ruleValue: get_rule_time(),
                ruleStatus: $rule_status.val()
            };

            add_handler = $.post('/school/biz/clrule/_addData', update_params).done(function(_data, _status, _xhr){
                if(parseInt(_data['code'], 10)===0 && _data['success']==true){

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
                    dialog.title('新增熄灯规则');
                    dialog.statusbar([
                        '<div class="dialog-form-tip danger">',
                            '<i class="fa fa-info-circle"></i>&nbsp;',
                            _data['msg'],
                        '</div>'
                    ].join(''));
                }
            }).fail(function(_xhr, _status, _error) {
                dialog.title('新增熄灯规则');
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

            $rule_name = $(this.node).find('input.J_dialog_rule_name').eq(0);
            $rule_value_h = $(this.node).find('select.J_dialog_rule_value_h').eq(0);
            $rule_value_m = $(this.node).find('select.J_dialog_rule_value_m').eq(0);
            $rule_value_s = $(this.node).find('select.J_dialog_rule_value_s').eq(0);
            $rule_status = $(this.node).find('select.J_dialog_rule_status').eq(0);

            $rule_name.on('change focus', function(){
                dialog.statusbar(null);
            })
        }
    }).show();
});
</script>

</body>
</html>
