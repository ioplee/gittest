/**
 * Smarty Utils
 * @author tonyc726
 */

(function() {
    // 借鉴underscore，兼容浏览器及Node环境
    var root = typeof self == 'object' && self.self === self && self ||
        typeof global == 'object' && global.global === global && global ||
        this;

    // Create a safe reference to the Smarty object for use below.
    var Smarty = function(obj) {
        if (obj instanceof _) return obj;
        if (!(this instanceof _)) return new _(obj);
        this._wrapped = obj;
    };


    // Export the Smarty object for **Node.js**
    if (typeof exports != 'undefined' && !exports.nodeType) {
        if (typeof module != 'undefined' && !module.nodeType && module.exports) {
            exports = module.exports = _;
        }
        exports.Smarty = Smarty;
    } else {
        root.Smarty = Smarty;
    }

    // Current version.
    Smarty.VERSION = '0.0.1';

    // AMD registration happens at the end for compatibility with AMD loaders
    if (typeof define == 'function' && define.amd) {
        define('Smarty', [], function() {
            return Smarty;
        });
    }

    /**
     * [validate_card_luhn Luhn算法检验卡号]
     *
     * @param  {String} card_number [需要检验的卡号]
     * @return {Boolean}
     *
     * @via https://zh.wikipedia.org/wiki/Luhn%E7%AE%97%E6%B3%95
     * @author tonyc726
     */
    Smarty.validate_card_luhn = function(card_number){
        // 卡号字符串化并去除空格，仅保留数字
        var str_digits = (card_number+'').replace(/[\D]/g, '');

        // 银行卡号必须为12-19位数字
        if(!/^\d{12,19}$/.test(str_digits)){
            return false;
        }

        // 根据luhn规则，将卡号数组化，并反转顺序，以便于操作
        var luhn_digits = str_digits.split('').reverse(),
            // 取第1位作为后续的验证号码
            luhn_checkcode = parseInt(luhn_digits.shift(), 10);

        var loop_length = luhn_digits.length,
            loop_index = loop_length;

        var luhn_sum = 0;
        for(; loop_index>0; loop_index--){
            var _i = loop_length-loop_index,
                _k = parseInt(luhn_digits[_i], 10);
            var _add_val = _k;
            // 偶数字段 需要*2，并且大于10的数字要相加2个位数的值
            if((_i%2)===0){
                var _k2 = _k*2;
                switch (_k2) {
                    case 10: _add_val = 1; break;
                    case 12: _add_val = 3; break;
                    case 14: _add_val = 5; break;
                    case 16: _add_val = 7; break;
                    case 18: _add_val = 9; break;
                    default: _add_val = _k2;
                }
            }
            luhn_sum += _add_val;
        }

        /* 方法1
           1. 从校验位开始，从右往左，偶数位乘2，然后将两位数字的个位与十位相加；
           2. 计算所有数字的和（67）；
           3. 乘以9（603）；
           4. 取其个位数字（3），得到校验位。
         */
        // var luhn_sum9 = luhn_sum*9,
        //     luhn_sum9_last_code = parseInt((luhn_sum9+'').replace(/\d+(\d$)/, '$1'), 10);
        // return (luhn_sum9_last_code===luhn_checkcode);

        /* 方法2
           1. 从校验位(即不包括该位数)开始，从右往左，偶数位乘2（例如，7*2=14），然后将两位数字的个位与十位相加（例如，10：1+0=1）；
           2. 把得到的数字加在一起；
           3. 将数字的和取模10（本例中得到7），再用10去减（本例中得到3），得到校验位。
         */
        var luhn_sum_mod10 = luhn_sum%10,
            luhn_sum_checkcode = 10 - luhn_sum_mod10;
        return (luhn_sum_checkcode===luhn_checkcode);

        /* 方法3
           1. 从校验位(即不包括该位数)开始，从右往左，偶数位乘2（例如，7*2=14），然后将两位数字的个位与十位相加（例如，10：1+0=1）；
           2. 把得到的数字加在一起；
           3. 再加上检验位的数值，将结果取模10，如果余数为0，则符合规则。
         */
        // return (((luhn_sum+luhn_checkcode)%10) === 0);
    };

    /**
     * [Base64 编码/解码base64]
     * @via http://stackoverflow.com/questions/246801/how-can-you-encode-a-string-to-base64-in-javascript#246813
     * @via https://github.com/beatgammit/base64-js/blob/master/lib/b64.js
     * @return {Function}     [description]
     */
    Smarty.Base64 = (function(){
        // private property
        var _keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

        // private method for UTF-8 encoding
        function _utf8_encode(string) {
            string = string.replace(/\r\n/g,"\n");
            var utftext = "";

            for (var n = 0; n < string.length; n++) {

                var c = string.charCodeAt(n);

                if (c < 128) {
                    utftext += String.fromCharCode(c);
                }
                else if((c > 127) && (c < 2048)) {
                    utftext += String.fromCharCode((c >> 6) | 192);
                    utftext += String.fromCharCode((c & 63) | 128);
                }
                else {
                    utftext += String.fromCharCode((c >> 12) | 224);
                    utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                    utftext += String.fromCharCode((c & 63) | 128);
                }

            }

            return utftext;
        }

        // private method for UTF-8 decoding
        function _utf8_decode(utftext) {
            var string = "";
            var i = 0;
            var c = c1 = c2 = 0;

            while ( i < utftext.length ) {

                c = utftext.charCodeAt(i);

                if (c < 128) {
                    string += String.fromCharCode(c);
                    i++;
                }
                else if((c > 191) && (c < 224)) {
                    c2 = utftext.charCodeAt(i+1);
                    string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
                    i += 2;
                }
                else {
                    c2 = utftext.charCodeAt(i+1);
                    c3 = utftext.charCodeAt(i+2);
                    string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
                    i += 3;
                }

            }

            return string;
        }

        if(window.btoa && window.atob){
            // https://developer.mozilla.org/zh-CN/docs/Web/API/WindowBase64/btoa
            //
            // 在各浏览器中,使用 window.btoa 对Unicode字符串进行编码都会触发一个字符越界的异常.
            // 先把Unicode字符串转换为UTF-8编码,可以解决这个问题, 代码来自 http://ecmanaut.blogspot.com/2006/07/encoding-decoding-utf8-in-javascript.html
            return {
                encode: function(str){
                    return window.btoa(unescape(encodeURIComponent( str )));
                },
                decode: function(str){
                    return decodeURIComponent(escape(window.atob( str )));
                }
            }
        }else{
            return {
                encode: function(input) {
                    var output = "";
                    var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
                    var i = 0;

                    input = _utf8_encode(input);

                    while (i < input.length) {

                        chr1 = input.charCodeAt(i++);
                        chr2 = input.charCodeAt(i++);
                        chr3 = input.charCodeAt(i++);

                        enc1 = chr1 >> 2;
                        enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
                        enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
                        enc4 = chr3 & 63;

                        if (isNaN(chr2)) {
                            enc3 = enc4 = 64;
                        } else if (isNaN(chr3)) {
                            enc4 = 64;
                        }

                        output = output +
                        _keyStr.charAt(enc1) + _keyStr.charAt(enc2) +
                        _keyStr.charAt(enc3) + _keyStr.charAt(enc4);

                    }

                    return output;
                },
                decode: function(input) {
                    var output = "";
                    var chr1, chr2, chr3;
                    var enc1, enc2, enc3, enc4;
                    var i = 0;

                    input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

                    while (i < input.length) {

                        enc1 = _keyStr.indexOf(input.charAt(i++));
                        enc2 = _keyStr.indexOf(input.charAt(i++));
                        enc3 = _keyStr.indexOf(input.charAt(i++));
                        enc4 = _keyStr.indexOf(input.charAt(i++));

                        chr1 = (enc1 << 2) | (enc2 >> 4);
                        chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
                        chr3 = ((enc3 & 3) << 6) | enc4;

                        output = output + String.fromCharCode(chr1);

                        if (enc3 != 64) {
                            output = output + String.fromCharCode(chr2);
                        }
                        if (enc4 != 64) {
                            output = output + String.fromCharCode(chr3);
                        }

                    }

                    output = _utf8_decode(output);

                    return output;
                }
            }
        }
    })();


    /**
     * [addParameter 给URL增加参数]
     * @param {[String]}  url            [需要修改的路径]
     * @param {[String]}  parameterName  [参数名称]
     * @param {[String]}  parameterValue [参数值]
     * @param {[Boolean]} atStart        [是否前置]
     */
    Smarty.addParameter = function(url, parameterName, parameterValue, atStart/*Add param before others*/){
        replaceDuplicates = true;
        if(url.indexOf('#') > 0){
            var cl = url.indexOf('#');
            urlhash = url.substring(url.indexOf('#'),url.length);
        } else {
            urlhash = '';
            cl = url.length;
        }
        sourceUrl = url.substring(0,cl);

        var urlParts = sourceUrl.split("?");
        var newQueryString = "";

        if (urlParts.length > 1 && urlParts[1] != '')
        {
            var parameters = urlParts[1].split("&");
            for (var i=0; (i < parameters.length); i++)
            {
                var parameterParts = parameters[i].split("=");
                if (!(replaceDuplicates && parameterParts[0] == parameterName))
                {
                    if (newQueryString == "")
                        newQueryString = "?";
                    else
                        newQueryString += "&";
                    newQueryString += parameterParts[0] + "=" + (parameterParts[1]?parameterParts[1]:'');
                }
            }
        }
        if (newQueryString == "")
            newQueryString = "?";

        if(atStart){
            newQueryString = '?'+ parameterName + "=" + parameterValue + (newQueryString.length>1?'&'+newQueryString.substring(1):'');
        } else {
            if (newQueryString !== "" && newQueryString != '?')
                newQueryString += "&";
            newQueryString += parameterName + "=" + (parameterValue?parameterValue:'');
        }
        return urlParts[0] + newQueryString + urlhash;
    }
})();
