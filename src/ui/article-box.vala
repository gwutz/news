/*
 * article-box.vala
 * This file is part of news
 *
 * Copyright (C) 2017 - Günther Wutz
 *
 * news is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * news is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with news. If not, see <http://www.gnu.org/licenses/>.
 */

namespace News.UI {

    public class ArticleBox : Gtk.Overlay {
        public Post post { get; set; }
        public Gtk.Image img;
        private Gtk.Spinner spinner;
        
        public ArticleBox (Post post) {
            Object ();
            spinner = new Gtk.Spinner ();
            spinner.get_style_context ().add_class ("postspinner");
            this.height_request = 256;
            this.width_request = 256;
            
            img = new Gtk.Image ();
            img.get_style_context ().add_class ("feedbox");
            this.add (img);
            
            set_post_data (post);
            
            this.valign = Gtk.Align.START;
            this.show_all ();
        }
        
        // FIXME: Use properties for setting!
        public void set_post_data (Post post) {
            if (!post.thumb_exists) {
                spinner.start ();
                post.thumb_ready.connect (show_image);
                add_overlay (spinner);
            } else {
                Lumber.Company.get_instance ().enqueue (new News.Background.ImageLoader(this));
                //img.set_from_file (post.thumbnail);
            }
            this.post = post;
            if (post.read) {
                img.set_opacity (0.5);
            }
        }
        
        public void clear () {
            post = null;
            img.clear ();
        }
        
        private void show_image () {
            spinner.stop ();
            remove (spinner);
            img.set_from_file (post.thumbnail);
            show_all ();
            post.thumb_ready.disconnect (show_image);
        }
    }
}
