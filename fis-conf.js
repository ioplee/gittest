// 设置项目属性
fis.set('project.name', 'school');
fis.set('project.static', '/asserts_v1');
fis.set('project.files', ['*.jsp', 'map.json', '/test/*']);

// 引入模块化开发插件，设置规范为 commonJs 规范。
fis.hook('commonjs', {
    baseUrl: '/assets',
    extList: ['.js', '.es'],
    paths: {
        $: 'vendors/jquery/dist/jquery.js',
        jquery: 'vendors/jquery/dist/jquery.js',
        dialog: 'vendors/art-dialog/dist/dialog.js',
        select2: 'vendors/select2/dist/js/select2.js',
        url: 'vendors/js-url/url.js',
        datepicker: 'vendors/bootstrap-datepicker/dist/js/bootstrap-datepicker.js'
    }
});

fis.match('*', {
    deploy: fis.plugin('local-deliver', {
        //to: '/usr/local/Cellar/tomcat/8.0.35/libexec/webapps/school'
        to :'/Users/robin/git/projects/g/target'
    })
});

/*************************目录规范*****************************/

// ------ 配置components
fis.match('/components/**', {
    release: false
});
fis.match('/components/(**.{js, es})', {
    parser: fis.plugin('babel-5.x'),
    rExt: 'js',
    isMod: true,
    release: '${project.static}/scripts/$1$2'
});

fis.match('**.scss', {
    postprocessor : fis.plugin("autoprefixer",{
        "browsers": ["> 1%", "last 2 versions"],
        "cascade": true,
        "remove": true
    }),
    parser: fis.plugin('node-sass', {
        include_paths: ['/assets/vendors', '/assets/styles', '/components'] // 加入文件查找目录
    }),
    rExt: '.css',
    isMod: true
});

// 开启同名依赖
fis.match('{/assets/scripts/**, /assets/vendors/**}', {
    useSameNameRequire: true
});

// ------ 配置assets
fis.match('/assets/(**)', {
    release: '${project.static}/$1'
});
// 配置css
fis.match('/assets/(styles/**.scss)', {
    release: '${project.static}/$1'
});
// // 配置image
// fis.match('/assets/(images/**)', {
//     release: '${project.static}/$1'
// });
// // 配置font
// fis.match('/assets/(fonts/**)', {
//     release: '${project.static}/$1'
// });
// 配置js
fis.match('/assets/(scripts/**.{js, es})', {
    parser: fis.plugin('babel-5.x'),
    rExt: 'js',
    isMod: false,
    release: '${project.static}/$1'
});

// ------ 配置vendors
fis.match('/assets/vendors/**', {
    release: false
});
fis.match('/assets/vendors/(**.css)', {
    isMod: true,
    release: '${project.static}/styles/$1'
});
fis.match('/assets/(vendors/**.scss)', {
    release: '${project.static}/$1'
});
fis.match('/assets/(vendors/**.js)', {
    isMod: true,
    release: '${project.static}/$1'
});
fis.match('/assets/vendors/({mod, jquery})/**.js', {
    isMod: false
});
fis.match('assets/(vendors/font-awesome/fonts/**)', {
    release: '${project.static}/$1'
});

// ------ 配置pages
fis.match('/pages/**', {
    release: false
});
fis.match('/pages/(**.jsp)', {
    isHtmlLike: true,
    release: '/WEB-INF/V1/$1'
});
fis.match('/pages/(*)/(*.css)', {
    release: '${project.static}/styles/page_$1'
});
fis.match('/pages/(*)/(*.scss)', {
    release: '${project.static}/styles/page_$1'
});
fis.match('/pages/(**.{js, es})', {
    parser: fis.plugin('babel-5.x'),
    rExt: 'js',
    isMod: true,
    release: '${project.static}/scripts/$1$2'
});
fis.match('/pages/(**.png)', {
    isMod: true,
    release: '${project.static}/images/$1'
});
fis.match('/pages/(**.jpg)', {
    isMod: true,
    release: '${project.static}/images/$1'
});
fis.match('/pages/(**.jepg)', {
    isMod: true,
    release: '${project.static}/images/$1'
});
fis.match('/pages/(**.gif)', {
    isMod: true,
    release: '${project.static}/images/$1'
});

/*************************打包规范*****************************/

// 因为是纯前端项目，依赖不能自断被加载进来，所以这里需要借助一个 loader 来完成，
// 注意：与后端结合的项目不需要此插件!!!
fis.match('::package', {
    // npm install [-g] fis3-postpackager-loader
    // 分析 __RESOURCE_MAP__ 结构，来解决资源加载问题
    postpackager: fis.plugin('loader', {
        resourceType: 'commonjs',
        useInlineMap: true // 资源映射表内嵌
    })
});


// 公用js
var map = {
    'dev': {
        host: '',
        path: '/${project.name}'
    },
    'prd': {
        host: '',
        path: '/${project.name}'
    }
};

fis.util.map(map, function (k, v) {
    var domain = v.host + v.path;

    fis.media(k)
        .match('**.{es,js}', {
            domain: domain
        })
        .match('(**.{scss,css})', {
            useSprite: true,
            domain: domain
        })
        .match('::image', {
            domain: domain
        })
        // 启用打包插件，必须匹配 ::package
        .match('::package', {
            spriter: fis.plugin('csssprites', {
                layout: 'matrix',
                // scale: 0.5, // 移动端二倍图用
                margin: '10'
            })
        })
        .match('/assets/vendors/({mod, jquery})/**.js', {
            packTo: '${project.static}/scripts/vendors.js'
        })
        .match('/assets/scripts/**.js', {
            packTo: '${project.static}/scripts/common.js'
        })
        .match('/components/**.{es,js}', {
            packTo: '${project.static}/scripts/components.js'
        })
        .match('/components/**.{scss,css}', {
            packTo: '${project.static}/styles/components.css'
        })
        .match('/pages/(!login)/**.{scss,css}', {
            packTo: '${project.static}/styles/app.css'
        })
});


fis.match('map.json', {
    release: '${project.static}/map.json'
});


// 发布产品库
fis.media('prd')
    .match('**.{es,js}', {
        useHash: true,
        optimizer: fis.plugin('uglify-js')
    })
    .match('**.jsp:js', {
        optimizer: fis.plugin('uglify-js')
    })
    .match('**.{scss,css}', {
        useHash: true,
        optimizer: fis.plugin('clean-css', {
            'keepBreaks': true //保持一个规则一个换行
        })
    })
    .match('**.jsp', {
        optimizer: fis.plugin('html-minifier', {
            removeComments:                true
           ,removeCommentsFromCDATA:       true
           ,removeCDATASectionsFromCDATA:  true
           ,collapseWhitespace:            true
           ,collapseBooleanAttributes:     true
        //    ,removeAttributeQuotes:         true
        //    ,removeRedundantAttributes:     true
           ,useShortDoctype:               true
        //    ,removeEmptyAttributes:         true
        //    ,removeEmptyElements:           true
        //    ,removeOptionalTags:            true
        //    ,removeScriptTypeAttributes:    true
        //    ,removeStyleLinkTypeAttributes: true
        })
    })
    .match('::image', {
        useHash: true
    })
    .match('*.png', {
        // fis-optimizer-png-compressor 插件进行压缩，已内置
        optimizer: fis.plugin('png-compressor')
    });
