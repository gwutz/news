/*
 * gnome-news-widget-factory.vala
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

namespace News.UI {

    public class WidgetFactory : Object {
    
        private Queue<Gtk.FlowBoxChild> flow_childs = new Queue<Gtk.FlowBoxChild>();
        private Queue<Gtk.ListBoxRow> list_childs = new Queue<Gtk.ListBoxRow>();
        
        public Gtk.FlowBoxChild get_article_box (Post post) {
            if (flow_childs.is_empty ()) {
                var outer = new Gtk.FlowBoxChild ();
                outer.add (new ArticleBox (post));
                outer.show ();
                return outer;
            }
            
            var outer = flow_childs.pop_head ();
            var box = outer.get_child () as ArticleBox;
            assert (box != null);
            box.set_post_data (post);
            outer.show ();
            return outer;
        }
        
        public void remove_article_box (Gtk.FlowBoxChild outer) {
            var box = outer.get_child () as ArticleBox;
            assert (box != null);
            box.clear ();
            flow_childs.push_head (outer);
        }
    
    }

}
