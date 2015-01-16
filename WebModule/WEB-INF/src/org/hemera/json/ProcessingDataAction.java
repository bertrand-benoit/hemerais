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

package org.hemera.json;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;

import org.hemera.utils.HemeraUtils;

import com.opensymphony.xwork2.ActionSupport;

/**
 * Hemera - Intelligent System
 * Web Service processing data controller.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 0.2
 */
public final class ProcessingDataAction extends ActionSupport {

    /****************************************************************************************/
    /*                                                                                      */
    /* Constants                                                                            */
    /*                                                                                      */
    /****************************************************************************************/

    private static final long serialVersionUID = -6885619098741741825L;

    /****************************************************************************************/
    /*                                                                                      */
    /* Attributes                                                                           */
    /*                                                                                      */
    /****************************************************************************************/

    /****************************************************************************************/
    /*                                                                                      */
    /* Implementation of ActionSupport                                                      */
    /*                                                                                      */
    /****************************************************************************************/

    /****************************************************************************************/
    /*                                                                                      */
    /* Getters / Setters                                                                    */
    /*                                                                                      */
    /****************************************************************************************/

    /****************************************************************************************/
    /*                                                                                      */
    /* Specific methods                                                                     */
    /*                                                                                      */
    /****************************************************************************************/

    /**
     * @return the data.
     */
    public final Map<String, long[]> getData() {

        final long uptime = Calendar.getInstance(TimeZone.getDefault()).getTimeInMillis();
        final Map<String, long[]> data = new HashMap<String, long[]>();
        data.put("new", new long[] { uptime, HemeraUtils.getNewInputCount() });
        data.put("error", new long[] { uptime, HemeraUtils.getErrorInputCount() });
        data.put("pspeech", new long[] { uptime, HemeraUtils.getCurInputCount("speech") });
        data.put("precordedSpeech", new long[] { uptime, HemeraUtils.getCurInputCount("recordedSpeech") });
        data.put("precognitionResult", new long[] { uptime, HemeraUtils.getCurInputCount("recognitionResult") });

        return data;
    }

}
