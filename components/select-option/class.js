/**
 * findSelect select联动本地储存
 */
var SOURCE_DICT = {
    'class': []
};

var SOURCE_PATH = {
    'class': '/school/biz/schoolBase/_selectClassOptions'
};

var SOURCE_CONFIG = {
    'class': {}
};


function get_data(_dict_aliase, _done_callback, _fail_callback, _always_callback){
    $.getJSON(SOURCE_PATH[_dict_aliase], SOURCE_CONFIG[_dict_aliase])
        .done(function(_data, _status, _xhr){
            if(parseInt(_data['code'], 10)===0){
                // update local dict
                update_data(_data['dataObject'], _dict_aliase);

                $.isFunction(_done_callback) && _done_callback(_data['dataObject']);
            }else{
                $.isFunction(_fail_callback) && _fail_callback();
            }
        }).fail(function(_xhr, _status, _error) {
            $.isFunction(_fail_callback) && _fail_callback(_status);
        }).always(function(_data, _status, _error) {
            $.isFunction(_always_callback) && _always_callback(_data);
        });
}

function update_data(_data, _dict_aliase){
    var dict_aliase = _dict_aliase + '';
    $.extend(SOURCE_DICT[dict_aliase], _data);
}

function check_local_status(_dict_aliase){
    var dict_aliase = _dict_aliase + '';
    return (SOURCE_DICT[dict_aliase].length===0) ? false : true;
}

exports.get = function(_params, _callback){
    var dict_aliase = _params['dictAliase'] + '';

    if(check_local_status(dict_aliase)){
        $.isFunction(_callback) && _callback(SOURCE_DICT[dict_aliase]);
        return SOURCE_DICT[dict_aliase];
    }else{
        get_data(dict_aliase, function(_data){
            $.isFunction(_callback) && _callback(_data);
        });
    }
};

exports.get_name_by_value = function(_params, _callback){
    var params = $.extend({}, {
            dictAliase: null,
            value: null,
            valAliase: null,
            keyAliase: null
        }, _params);

    var dict_aliase = params['dictAliase'] + '',
        value = (params['value']===null) ? '' : params['value'] + '',
        valAliase = (params['valAliase']===null) ? '' : params['valAliase'] + '',
        keyAliase = (params['keyAliase']===null) ? '' : params['keyAliase'] + '';

    var result = null;

    $.each(SOURCE_DICT[dict_aliase], function(_i, _item_data){
        if(_item_data[valAliase]==value){
            result = _item_data[keyAliase];
            $.isFunction(_callback) && _callback(_item_data[keyAliase]);
            
        }
    });

    return result;
};
