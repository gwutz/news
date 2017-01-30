/*
 * gnome-news-thumb.vala
 * This file is part of gnome-news
 *
 * Copyright (C) 2017 - Günther Wutz
 *
 * gnome-news is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * gnome-news is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with gnome-news. If not, see <http://www.gnu.org/licenses/>.
 */

namespace GnomeNews {
    public class Thumb : Object {
        private WebKit.WebView webview;
        private Post post;
        
        public Thumb () {
            this.webview = new WebKit.WebView ();
            this.webview.sensitive = false;
            this.webview.load_changed.connect (draw_thumbnail);
        }
        
        public void generate_thumbnail (Post p) {
            this.post = p;
            var author = p.author != null ? p.author : "";
            this.webview.load_html("""
                <div style="width: 250px">
                <h3 style="margin-bottom: 2px">%s</h3>
                <small style="color: #333">%s</small>
                <small style="color: #9F9F9F">%s</small>
                </div>
            """.printf (p.title, author, p.content), null);
        }
        
        private void draw_thumbnail (WebKit.LoadEvent event) {
            print ("thumb: %s\n", post.thumbnail);
            if (event == WebKit.LoadEvent.FINISHED) {
                this.webview.get_snapshot.begin (WebKit.SnapshotRegion.FULL_DOCUMENT,
                                                 WebKit.SnapshotOptions.NONE,
                                                 null, 
                                                 (obj, res) => {
                    try {
                        var surface = this.webview.get_snapshot.end(res);
                        var new_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, 256, 256);
                        var ctx = new Cairo.Context(new_surface);
                        ctx.set_source_surface(surface, 0, 0);
                        ctx.paint ();
                        new_surface.write_to_png (post.thumbnail);
                        post.thumbnailer = null;
                    } catch (Error e) {
                        error (e.message);
                    }
                    
                });
            }
        }
        
    }
}
