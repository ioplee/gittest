/**
 * findSelect select联动本地储存
 */
var SOURCE_DICT = {
    'deviceType': [],
    'deviceLevel': [],
    'nodeType': []
};


function get_data(_biz_type, _done_callback, _fail_callback, _always_callback){
    $.getJSON('/school/V1/DeviceUtrilsService/_nodeTypeSelectOptions', {
        bizType: _biz_type
    }).done(function(_data, _status, _xhr){
        if(parseInt(_data['code'], 10)===0){
            // update local dict
            update_data(_data['dataObject'], _biz_type);

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

function update_data(_data, _biz_type){
    var biz_type = _biz_type + '';
    $.extend(SOURCE_DICT[biz_type], _data);
}

function check_local_status(_biz_type){
    var biz_type = _biz_type + '';
    return (SOURCE_DICT[biz_type].length===0) ? false : true;
}

exports.get = function(_params, _callback){
    var biz_type = _params['bizType'] + '';

    if(check_local_status(biz_type)){
        $.isFunction(_callback) && _callback(SOURCE_DICT[biz_type]);
        return SOURCE_DICT[biz_type];
    }else{
        get_data(biz_type, function(_data){
            $.isFunction(_callback) && _callback(_data);
        });
    }
};

exports.get_name_by_value = function(_params, _callback){
    var biz_type = _params['bizType'] + '',
        value = (_params['value']===null) ? '' : _params['value'] + '';

    $.each(SOURCE_DICT[biz_type], function(_i, _item_data){
        if(_item_data['value']==value){
            $.isFunction(_callback) && _callback(_item_data['name']);
            
        }
    });
};
