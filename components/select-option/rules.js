/**
 * findSelect select联动本地储存
 */
var SOURCE_DICT = {
    'closeLights': [],
    'appraisalRules': []
};

var SOURCE_PATH = {
    'closeLights': '/school/V1/DeviceUtrilsService/_closeLightsRuleOptions',
    'appraisalRules': '/school/biz/AppraisalRule/_ruleSelectOptions'
};

var SOURCE_CONFIG = {
    'closeLights': {},
    'appraisalRules': {}
};


function get_data(_rule_aliase, _done_callback, _fail_callback, _always_callback){
    $.getJSON(SOURCE_PATH[_rule_aliase], SOURCE_CONFIG[_rule_aliase])
        .done(function(_data, _status, _xhr){
            if(parseInt(_data['code'], 10)===0){
                // update local dict
                update_data(_data['dataObject'], _rule_aliase);

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

function update_data(_data, _rule_aliase){
    var rule_aliase = _rule_aliase + '';
    $.extend(SOURCE_DICT[rule_aliase], _data);
}

function check_local_status(_rule_aliase){
    var rule_aliase = _rule_aliase + '';
    return (SOURCE_DICT[rule_aliase].length===0) ? false : true;
}

exports.get = function(_params, _callback){
    var rule_aliase = _params['ruleAliase'] + '';

    if(check_local_status(rule_aliase)){
        $.isFunction(_callback) && _callback(SOURCE_DICT[rule_aliase]);
        return SOURCE_DICT[rule_aliase];
    }else{
        get_data(rule_aliase, function(_data){
            $.isFunction(_callback) && _callback(_data);
        });
    }
};

exports.get_name_by_value = function(_params, _callback){
    var params = $.extend({}, {
            ruleAliase: null,
            value: null,
            valAliase: null,
            keyAliase: null
        }, _params);

    var rule_aliase = params['ruleAliase'] + '',
        value = (params['value']===null) ? '' : params['value'] + '',
        valAliase = (params['valAliase']===null) ? '' : params['valAliase'] + '',
        keyAliase = (params['keyAliase']===null) ? '' : params['keyAliase'] + '';

    var result = null;

    $.each(SOURCE_DICT[rule_aliase], function(_i, _item_data){
        if(_item_data[valAliase]==value){
            result = _item_data[keyAliase];
            $.isFunction(_callback) && _callback(_item_data[keyAliase]);
            
        }
    });

    return result;
};
