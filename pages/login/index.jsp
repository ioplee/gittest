<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="import" href="/components/head_meta/meta.html?__inline">

    <title>智能控制-基础配置-楼宇</title>

    <link rel="stylesheet" href="./login.scss" charset="utf-8">

    <script src="assets/vendors/jquery/dist/jquery.js" charset="utf-8"></script>
</head>
<body>

    <div class="ui-header">
        <div class="ui-container">
            <img src="assets/images/logo.png" alt="" class="header-logo">
        </div>
    </div>
    <div class="ui-body">
        <img src="./banner1.jpg" alt="" class="login-banner">
        <div class="login-panel">
            <h2 class="panel__title">用户登录</h2>
            <form action="/" class="panel__main login-form">
                <div class="form__group">
                    <label for="" class="form-label"><i class="fa fa-user"></i></label>
                    <input type="text" class="form-input" placeholder="用户名">
                </div>
                <div class="form__group">
                    <label for="" class="form-label"><i class="fa fa-lock"></i></label>
                    <input type="password" class="form-input" placeholder="密码">
                </div>
                <input type="submit" value="立即登录" class="form-submit ui-button ui-button-block">
                <div class="form__extra">
                    <label for="" class="form-check"><input type="checkbox" name="" id="" class="">记录密码</label>
                </div>
            </form>
        </div>
    </div>
    <div class="login-banner" id="login_banner">
        <div class="J_slider">
            <ul>
                <li><img src="" alt=""></li>
                <li><img src="./banner2.jpg" alt=""></li>
                <li><img src="./banner3.jpg" alt=""></li>
            </ul>
        </div>
    </div>


<script>
$(function(){

    $('#login_banner').css({
        width: $(document).width(),
        height: $(document).height()
    }).find('.J_slider').unslider({
        animation:'fade',
        autoplay:true,
        arrows: false,
        speed:500,
        delay:3000
    });
});
</script>

</body>
</html>
