var MBTiles = {
    getTile: function(tile, success, fail) {
        return PhoneGap.exec(success, fail, 'MBTiles', 'getTile', tile);
    }
};

function appReady() {
    var mm = com.modestmaps;
    var tilejson = 'http://d.tiles.mapbox.com/v2/mapbox.dc-bright.jsonp';
        wax.tilejson(tilejson, function(tj) {
        m = new mm.Map('map',
        new mm.TemplatedMapProvider('images/blank.png#{Z},{X},{Y}'), null, [
            new mm.TouchHandler(),
            new mm.MouseHandler()
        ]);
        m.setCenterZoom(
            new mm.Location(tj.center[1], tj.center[0]),
                tj.center[2]);
        m.addCallback('drawn', function() {
            var images = document.getElementsByTagName('img');
            console.log(m.tiles);
            for (var i in m.tiles) {
                var mt = m.tiles[i];
                if (mt.src.match(/blank\.png\#(.+)$/)) {
                    var t = mt.src.match(/blank\.png\#(.+)$/)[1];
                    var cc = t.split(',').map(function(x) { return parseInt(x, 10); });
                    cc[2] = Math.pow(2, cc[0]) - cc[2] - 1;
                    (function(im, t) {
                        MBTiles.getTile([t],
                        function(tile) {
                            im.src='data:image/png;base64,' + tile;
                            im.style.width = '256px';
                            im.style.height = '256px';
                        },
                        function() {
                            // im.src='data:image/png;base64,' + arguments[0];
                        });
                    })(images[i], cc.join(','));
                }
            }
        });
    });

}

if (document.ondeviceready) {
document.addEventListener('deviceready', appReady, false);
} else {
  window.addEventListener('load', appReady, false);
}
