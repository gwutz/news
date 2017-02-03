/*
 * tracker.vala
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

namespace News {

    [DBus (name = "org.freedesktop.Tracker1.Miner")]
    public interface TrackerRss : Object {
        public abstract void Start() throws IOError;

    }

    [DBus (name = "org.freedesktop.Tracker1.Resources")]
    public interface Tracker : Object {
        [DBus (name = "GraphUpdated")]
        public signal void graph_updated(string classname, ResourcesDeleteStruct[] deletes, ResourcesInsertStruct[] inserts);

    }

    public struct ResourcesDeleteStruct {
        public int attr1;
        public int attr2;
        public int attr3;
        public int attr4;
    }

    public struct ResourcesInsertStruct {
        public int attr1;
        public int attr2;
        public int attr3;
        public int attr4;
    }
}
