/**
 * 侧边栏通用组件交互
 */

// var $ = require('jquery');

var $menu_container = $('#sidebar_menu'),
    $menu_list = $menu_container.find('li.menu__item');

function _has_submenu(_$menu){
    return $('ol.menu-sublist', _$menu).length ? true : false;
}

function toggle_menu_list(_$menu){
    _$menu.toggleClass('menu__item_toggle');
}

function active_submenu(_$menu, _submenu_name){
    _$menu.find('li.sublist__item').filter(function(){
        return ~$(this).data('submenu').indexOf(_submenu_name);
    }).eq(0).addClass('sublist__item_active');
}

$menu_list.on('click.common', 'a.J_menu_toggle', function(){
    toggle_menu_list($(this).parent('li.menu__item').eq(0));
    return false;
});


exports.init = function(_menu_name, _submenu_name){
    if(typeof _menu_name === 'string' || _menu_name instanceof String){
        var $menu = $menu_list.filter(function(){
            return ~$(this).data('menu').indexOf(_menu_name);
        }).eq(0);

        if((typeof _submenu_name === 'string' || _submenu_name instanceof String) && _has_submenu($menu)){
            toggle_menu_list($menu);
            active_submenu($menu, _submenu_name);
        }else{
            $menu.addClass('menu__item_active');
        }
    }
};
