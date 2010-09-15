/*
 * Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
 * Copyright (C) 2010 Bertrand Benoit <projettwk@users.sourceforge.net>
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

import java.util.logging.ConsoleHandler;
import java.util.logging.Level;
import java.util.logging.LogRecord;

/**
 * Hemera - Intelligent System
 * Log specific console handler (error output by default, used another consoler handler otherwise).
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 1.0.0
 */
public class LogConsoleHandler extends ConsoleHandler {

	/****************************************************************************************/
	/*                                                                                      */
	/* Constants */
	/*                                                                                      */
	/****************************************************************************************/

	/** Standard output for console handler. */
	private static final ConsoleStandardOutputHandler standardOutput = new ConsoleStandardOutputHandler();

	/****************************************************************************************/
	/*                                                                                      */
	/* Attributes */
	/*                                                                                      */
	/****************************************************************************************/

	/****************************************************************************************/
	/*                                                                                      */
	/* Constructors */
	/*                                                                                      */
	/****************************************************************************************/

	public LogConsoleHandler() {
		super();
		setFormatter(Log.FORMATTER);
	}

	/****************************************************************************************/
	/*                                                                                      */
	/* Getters / Setters */
	/*                                                                                      */
	/****************************************************************************************/

	/****************************************************************************************/
	/*                                                                                      */
	/* Specific methods */
	/*                                                                                      */
	/****************************************************************************************/

	/****************************************************************************************/
	/*                                                                                      */
	/* Overrides */
	/*                                                                                      */
	/****************************************************************************************/

	/**
	 * @see java.util.logging.ConsoleHandler#publish(java.util.logging.LogRecord)
	 */
	@Override
	public void publish(final LogRecord record) {
		// Ensures the record is loggable.
		if (super.isLoggable(record)) {
			// According to level, publish on error output, or standard output.
			if (record.getLevel().intValue() >= Level.WARNING.intValue()) {
				super.publish(record);
			} else {
				standardOutput.publish(record);
			}
		}
	}

	/**
	 * @see java.util.logging.Handler#setLevel(java.util.logging.Level)
	 */
	@Override
	public synchronized final void setLevel(final Level newLevel) {
		super.setLevel(newLevel);
		standardOutput.setLevel(newLevel);
	}

}
