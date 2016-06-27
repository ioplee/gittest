<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>短信管理-发件箱</title>

    <link rel="stylesheet" href="assets/styles/common.scss" charset="utf-8">
    <link rel="stylesheet" href="./message.scss" charset="utf-8">

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
                <span class="breadcrumb-active">短信管理</span>
                <span class="breadcrumb-split">/</span>
                <span class="breadcrumb-active">发件箱</span>
            </div>

            <div class="body-content__wrapper">
                <div class="ui-panel">
                    <div class="panel__header">
                        <span class="panel-title"><i class="fa fa-list"></i>&nbsp;楼宇列表</span>
                    </div>
                    <div class="panel__body">
                        <!-- <div class="panel-toolbar">
                            <div class="ui-search-group">
                                <label for="" class="search-label">快速检索：</label>
                                <input type="text" class="ui-input search__item_first" value="" placeholder="楼宇检索">
                                <a href="javascript:void(0);" class="ui-button ui-button-sm search__item_last"><i class="fa fa-search"></i></a>
                            </div>
                        </div> -->
                        <div class="ui-table-container">
                            <div class="ui-table-toolbar">
                                <a href="javascript:void(0);" class="ui-button-primary ui-button-sm" title="新增" id="building_add"><i class="fa fa-plus"></i>&nbsp;新增</a>
                            </div>
                            <table class="ui-table" id="building_list">
                                <thead>
                                    <tr>
                                        <th class="cell__checkbox"><input type="checkbox" name="" id="" class="J_select_all"></th>
                                        <th style="width: 30px;">序号</th>
                                        <th>楼宇名称</th>
                                        <th>描述</th>
                                        <th style="width: 60px;">状态</th>
                                        <th style="width: 80px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                        <div class="ui-table-paging" id="building_list_paging"></div>
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
    SidebarMenu.init('message', 'list');
});

var ArtDialog = require('dialog'),
    Url = require('url'),
    Paging = require('/components/paging/paging.js');

</script>

</body>
</html>
