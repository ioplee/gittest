/**
 * findSelect select联动本地储存
 */
var SOURCE_DICT = {
    'building': [],
    'buildingLevel': {},
    'room': {},
    'gateway': {}
};

var NO_KEY_HASH = {
    'building': 'building_no',
    'buildingLevel': 'level_no',
    'room': 'room_no',
    'gateway': 'gateway_no'
};

function get_data(_biz_type, _no, _done_callback, _fail_callback, _always_callback){
    var params = {
        bizType: ((_biz_type=='buildingLevel')?'building_level':_biz_type)
    };
    if(_no!==null){
        params['no'] = _no;
    }
    $.getJSON('/school/V1/DeviceUtrilsService/_findSelect', params).done(function(_data, _status, _xhr){
        if(parseInt(_data['code'], 10)===0){
            // update local dict
            update_data(_data['dataObject'], _biz_type, _no);

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

function update_data(_data, _biz_type, _no){
    var biz_type = _biz_type + '',
        no = _no + '';
    if(_biz_type==='building'){
        $.extend(SOURCE_DICT[biz_type], _data);
    }else{
        if(!!SOURCE_DICT[biz_type][no]){
            $.extend(SOURCE_DICT[biz_type][no], _data);
        }else{
            SOURCE_DICT[biz_type][no] = _data;
        }
    }
}

function check_local_status(_biz_type, _no){
    var biz_type = _biz_type + '',
        no = _no + '';
    return (biz_type==='building') ? ((SOURCE_DICT[biz_type].length===0) ? false : true) : (!!SOURCE_DICT[biz_type][no]) ? true : false;
}

exports.get = function(_params, _callback){
    var biz_type = _params['bizType'] + '',
        no = (_params['no']!==undefined && _params['no']!==null) ? (_params['no'] + '') : null;
    if(check_local_status(biz_type, no)){
        var result = (biz_type==='building') ? SOURCE_DICT[biz_type] : SOURCE_DICT[biz_type][no];
        $.isFunction(_callback) && _callback(result);
        return result;
    }else{
        get_data(biz_type, no, function(_data){
            $.isFunction(_callback) && _callback(_data);
        });
    }
};

exports.find = function(_params, _callback){
    var biz_type = _params['bizType'] + '',
        no = (_params['no']===null) ? '' : _params['no'] + '';

    var result = null;
    if(biz_type==='building'){
        $.each(SOURCE_DICT[biz_type], function(_i, _item_data){
            if(_item_data[NO_KEY_HASH[biz_type]]==no){
                result = _item_data;
                
            }
        });
    }else{
        $.each(SOURCE_DICT[biz_type], function(_parent_no, _item_data){
            $.each(_item_data, function(__i, __item_data){
                if(__item_data[NO_KEY_HASH[biz_type]]==no){
                    result = __item_data;
                    
                }
            });
            if(result!==null){
                
            }
        });
    }

    $.isFunction(_callback) && _callback(result);
    return result;
};
