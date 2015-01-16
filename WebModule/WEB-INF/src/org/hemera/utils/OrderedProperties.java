/*
 * Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
 * Copyright (C) 2010-2015 Bertrand Benoit <projettwk@users.sourceforge.net>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses
 * or write to the Free Software Foundation,Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA 02110-1301  USA
 */

package org.hemera.utils;

import java.util.Collections;
import java.util.Enumeration;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

/**
 * Hemera - Intelligent System
 * Properties implementation which keeps loaded file order.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 0.2
 */
public final class OrderedProperties extends Properties {

    /****************************************************************************************/
    /*                                                                                      */
    /* Constants                                                                            */
    /*                                                                                      */
    /****************************************************************************************/

    private static final long serialVersionUID = 1065594927434955726L;
    /****************************************************************************************/
    /*                                                                                      */
    /* Attributes                                                                           */
    /*                                                                                      */
    /****************************************************************************************/

    private final Map<Object, Object> orderedMap = new LinkedHashMap<Object, Object>();

    /****************************************************************************************/
    /*                                                                                      */
    /* Constructors                                                                         */
    /*                                                                                      */
    /****************************************************************************************/

    public OrderedProperties() {
        super();
    }

    public OrderedProperties(final Properties defaults) {
        super(defaults);
    }

    /****************************************************************************************/
    /*                                                                                      */
    /* Overrides of Properties methods                                                      */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @see java.util.Hashtable#keys()
     */
    @Override
    public final Enumeration<Object> keys() {
        return Collections.<Object> enumeration(orderedMap.keySet());
    }

    /**
     * @see java.util.Hashtable#put(java.lang.Object, java.lang.Object)
     */
    @Override
    public final Object put(final Object key, final Object value) {
        orderedMap.put(key, String.valueOf(value).replaceAll("\"", ""));
        return super.put(key, value);
    }

    /**
     * @see java.util.Hashtable#keySet()
     */
    @Override
    public final Set<Object> keySet() {
        return orderedMap.keySet();
    }

    /**
     * @see java.util.Hashtable#entrySet()
     */
    @Override
    public final Set<java.util.Map.Entry<Object, Object>> entrySet() {
        return orderedMap.entrySet();
    }

}
