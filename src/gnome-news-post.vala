/*
 * gnome-news-post.vala
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

using Tracker;
namespace GnomeNews {
    public class Post : Object {
        public Thumb thumbnailer = new Thumb ();
    
        public string title { get; set; }
        public string content { get; set; }
        public string url { get; set; }
        public string author { get; set; }
        public string thumbnail { get; set; }
        
        public Post (Sparql.Cursor cursor) {
            this.title = cursor.get_string(0);
            this.content = cursor.get_string(1);
            this.url = cursor.get_string(2);
            this.author = cursor.get_string(3);
            
            this.thumbnail = Application.CACHE + compute_hash () + ".png";
            if (!FileUtils.test (this.thumbnail, FileTest.EXISTS)) {
                Idle.add (() => {
                    thumbnailer.generate_thumbnail (this);
                    //thumbnailer = null;
                    return false;
                });
            }
        }
    
        private string compute_hash () {
            return Checksum.compute_for_string (ChecksumType.MD5, this.url);
        }
    }
}
