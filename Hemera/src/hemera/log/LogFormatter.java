/*
 * Hemera - Intelligent System (http://hemerais.bertrand-benoit.net)
 * Copyright (C) 2010-2015 Bertrand Benoit <hemerais@bertrand-benoit.net>
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

import java.text.DateFormat;
import java.util.Date;
import java.util.logging.Formatter;
import java.util.logging.LogRecord;

/**
 * Hemera - Intelligent System Log formatter.
 * Log formatter.
 * 
 * @author Bertrand Benoit <hemerais@bertrand-benoit.net>
 * @since 1.0.0
 */
final class LogFormatter extends Formatter {

	/****************************************************************************************/
	/*                                                                                      */
	/* Constants */
	/*                                                                                      */
	/****************************************************************************************/

	/** Date format. */
	private static final DateFormat DATE_FORMAT = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

	/** Spaces characters, used to align message part. */
	private static final String SPACES = "                              ";

	/** Defines column size of various log message parts. */
	private static final int LOGGER_NAME_COL_SIZE = 20;
	private static final int THREAD_ID_COL_SIZE = 5;
	private static final int SOURCE_CLASS_AND_METHOD_COL_SIZE = 50;
	private static final int LEVEL_COL_SIZE = 10;

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

	/**
	 * @param messageBuilder
	 *            builder to update.
	 * @param info
	 *            info to append.
	 * @param colLength
	 *            length of the column "where" to append info.
	 */
	private final void appendFormattedInformation(final StringBuilder messageBuilder, final String info, final int colLength) {
		final int infoLength = info.length();
		if (infoLength < colLength) {
			messageBuilder.append(SPACES, 0, colLength - infoLength);
		}
		messageBuilder.append(info);
	}

	/****************************************************************************************/
	/*                                                                                      */
	/* Overrides */
	/*                                                                                      */
	/****************************************************************************************/
	/**
	 * Formats log: <date> <logger name> <thread ID> <class name> <level> <message>
	 * 
	 * @see java.util.logging.Formatter#format(java.util.logging.LogRecord)
	 */
	@Override
	public final String format(final LogRecord record) {
		final StringBuilder messageBuilder = new StringBuilder(128);
		messageBuilder.append(DATE_FORMAT.format(new Date(record.getMillis()))).append("  ");
		appendFormattedInformation(messageBuilder, record.getLoggerName(), LOGGER_NAME_COL_SIZE);
		appendFormattedInformation(messageBuilder, "" + record.getThreadID(), THREAD_ID_COL_SIZE);
		appendFormattedInformation(messageBuilder, record.getSourceClassName() + "#" + record.getSourceMethodName(), SOURCE_CLASS_AND_METHOD_COL_SIZE);
		appendFormattedInformation(messageBuilder, record.getLevel().toString(), LEVEL_COL_SIZE);
		messageBuilder.append("  ").append(record.getMessage()).append('\n');

		return messageBuilder.toString();
	}

}
