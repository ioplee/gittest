/**
 * 分页公用组件
 */
var Url = require('url');

var link_path = '';

function render_html(_current_page_no, _total_page_no, _limit_size, _total_records){
    var tpl = [
            '<div class="ui-paging">',
                '<span class="paging-info">',
                    '当前&nbsp;第<span class="paging-info__num">'+ _current_page_no +'/'+ _total_page_no +'</span>页，',
                    '每页'+ _limit_size +'条，共'+ _total_records +'条',
                '</span>'
        ];
    if(_current_page_no===1){
        tpl.push([
            '<a href="javascript:void(0);" class="paging-btn disabled">首页</a>',
            '<a href="javascript:void(0);" class="paging-btn__prev disabled">',
                '<i class="fa fa-angle-left"></i>&nbsp;上一页',
            '</a>'
        ].join(''));
    }else{
        tpl.push([
            '<a href="'+ create_url(1, _limit_size, _total_page_no) +'" class="paging-btn">首页</a>',
            '<a href="'+ create_url((_current_page_no-1), _limit_size, _total_page_no) +'" class="paging-btn__prev">',
                '<i class="fa fa-angle-left"></i>&nbsp;上一页',
            '</a>'
        ].join(''));
    }

    if(_current_page_no===_total_page_no){
        tpl.push([
            '<a href="javascript:void(0);" class="paging-btn__next disabled">',
                '下一页&nbsp;<i class="fa fa-angle-right"></i>',
            '</a>',
            '<a href="javascript:void(0);" class="paging-btn disabled">末页</a>'
        ].join(''));
    }else{
        tpl.push([
            '<a href="'+ create_url((_current_page_no+1), _limit_size, _total_page_no) +'" class="paging-btn__next">',
                '下一页&nbsp;<i class="fa fa-angle-right"></i>',
            '</a>',
            '<a href="'+ create_url(_total_page_no, _limit_size, _total_page_no) +'" class="paging-btn">末页</a>'
        ].join(''));
    }
    return tpl.join('');
}


function create_url(_page_no, _limit_size, _total_page_no){
    var page_no = ((_page_no<=0) ? 1 : ((_page_no<=_total_page_no) ? _page_no : _total_page_no));

    var link = Smarty.addParameter(link_path, 'pageSize', _limit_size);
    link = Smarty.addParameter(link_path, 'pageNo', page_no);

    return link;
}

exports.init = function(_$container_id, _page_params){
    link_path = _page_params['path'] || Url();

    $('#'+_$container_id).html(render_html(_page_params['pageNo'], _page_params['totalPages'], _page_params['pageSize'], _page_params['records']));
};
