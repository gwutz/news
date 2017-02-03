/*
 * worker.vala
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

/* 
 * This code is generic and should be stripped out of news for a good library to handle
 * long running operations in a similiar way java handles long running operations in android
 * code. If we want to let a thread operate on long running operations, we subclass worker
 * and implement 
 */
namespace Lumber {
    
    public abstract class Worker<A> : Object {
    
        public abstract A do_in_background ();
        public abstract void on_post_execute (A result);
        
        internal void execute () {
            A result = do_in_background ();
            
            Idle.add (() => {
                on_post_execute (result);
                return false;
            });
        }
    }

}
