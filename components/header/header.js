/**
 * 头部菜单组件
 * Created by tony on 16/4/6.
 */
// var $ = require('jquery');

$('#header_menu').on('click.common', 'a.J_menu_toggle', function(e){
    e.stopPropagation();
    $(this).parent('li.menu__item').toggleClass('menu__item_toggle');
});

$(window).on('click.header_menu', function(){
    $('#header_menu').find('li.menu__item_toggle').removeClass('menu__item_toggle');
});
