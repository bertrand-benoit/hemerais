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

package hemera.log;

import java.util.logging.StreamHandler;

/**
 * Hemera - Intelligent System
 * Log specific console handler (standard output).
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 1.0.0
 */
class ConsoleStandardOutputHandler extends StreamHandler {

	/****************************************************************************************/
	/*                                                                                      */
	/* Constructors */
	/*                                                                                      */
	/****************************************************************************************/

	/**
	 * Creates a ConsoleOutHandler with System.out as output stream.
	 */
	ConsoleStandardOutputHandler() {
		setOutputStream(System.out);
		setFormatter(Log.FORMATTER);
	}

	/****************************************************************************************/
	/*                                                                                      */
	/* Specific methods */
	/*                                                                                      */
	/****************************************************************************************/

	/**
	 * @see java.util.logging.StreamHandler#publish(java.util.logging.LogRecord)
	 */
	@Override
	public void publish(final java.util.logging.LogRecord record) {
		super.publish(record);
		flush();
	}

	/**
	 * Override <tt>StreamHandler.close</tt> to do a flush but not
	 * to close the output stream. That is, we do <b>not</b>
	 * close <tt>System.out</tt>.
	 */
	/**
	 * @see java.util.logging.StreamHandler#close()
	 */
	@Override
	public void close() {
		flush();
	}

}
