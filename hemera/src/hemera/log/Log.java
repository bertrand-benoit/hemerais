/*
 * Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
 * Copyright (C) 2010-2011 Bertrand Benoit <projettwk@users.sourceforge.net>
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

import java.io.IOException;
import java.util.logging.ConsoleHandler;
import java.util.logging.FileHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.LogManager;
import java.util.logging.Logger;

/**
 * Hemera - Intelligent System General Log system.
 * Log functionalities provider.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 1.0.0
 */
public final class Log {

	/****************************************************************************************/
	/*                                                                                      */
	/* Constants */
	/*                                                                                      */
	/****************************************************************************************/

	/** Property allowing definition of log file. */
	private static final String LOG_FILE_PROPERTY = "hemera.log.file";

	/** Log file. */
	private static final String LOG_FILE = System.getProperty(LOG_FILE_PROPERTY);

	/** Property allowing definition of NOT logging on console. */
	private static final String LOG_CONSOLE_PROPERTY = "hemera.log.noConsole";

	/** Log on console. */
	private static final boolean LOG_CONSOLE = !Boolean.getBoolean(LOG_CONSOLE_PROPERTY);

	/** Property allowing definition of log verbose level (possible values: 0 to 3, 0=no verbose, 3=highly verbose). */
	private static final String VERBOSE_LEVEL_PROPERTY = "hemera.log.verbose";

	/** Verbose level. */
	private static final Level VERBOSE_LEVEL = defineVerboseLevel();

	/** Log formatter. */
	static final Formatter FORMATTER = new LogFormatter();

	/** The utils logger. */
	public static final Logger utils = Logger.getLogger("Hemera.utils");

	/****************************************************************************************/
	/*                                                                                      */
	/* Constructors */
	/*                                                                                      */
	/****************************************************************************************/

	// Checks if log file is defined, in which case a log handler is created.
	static {
		// Gets the root logger.
		final Logger rootLogger = LogManager.getLogManager().getLogger("");
		rootLogger.setLevel(VERBOSE_LEVEL);

		// Removes default handlers.
		for (final Handler handler : rootLogger.getHandlers()) {
			rootLogger.removeHandler(handler);
		}

		// Adds console handler, with Hemera Log formatter.
		if (LOG_CONSOLE) {
			final ConsoleHandler consoleHandler = new LogConsoleHandler();
			consoleHandler.setFormatter(FORMATTER);
			rootLogger.addHandler(consoleHandler);
			consoleHandler.setLevel(VERBOSE_LEVEL);
		}

		// Checks if log file is defined.
		if (LOG_FILE != null && LOG_FILE.length() != 0) {
			try {
				// It is the case, adds a file handler.
				final Handler logFileHandler = new FileHandler(LOG_FILE, true);
				logFileHandler.setFormatter(new LogFormatter());
				rootLogger.addHandler(logFileHandler);
			} catch (final SecurityException e) {
				System.err.println("Unable to initialize Hemera Log System.");
				e.printStackTrace();
			} catch (final IOException e) {
				System.err.println("Unable to initialize Hemera Log System.");
				e.printStackTrace();
			}
		}
	}

	/****************************************************************************************/
	/*                                                                                      */
	/* Specific methods */
	/*                                                                                      */
	/****************************************************************************************/

	/**
	 * @return verbose level according to {@link #VERBOSE_LEVEL_PROPERTY}.
	 */
	private static final Level defineVerboseLevel() {
		final int specifiedVerbose = Integer.getInteger(VERBOSE_LEVEL_PROPERTY, 0);
		switch (specifiedVerbose) {
		case 1:
			return Level.FINE;
		case 2:
			return Level.FINER;
		case 3:
			return Level.FINEST;
		default:
			return Level.INFO;
		}
	}

	/**
	 * Manages throwable according to verbose level.
	 * 
	 * @param t
	 *            throwable to manage.
	 */
	public static final void manageThrowable(final Throwable t) {
		manageThrowable(t, -1);
	}

	/**
	 * Manages throwable according to verbose level.
	 * If an exitValue != -1 is specified, {@link System#exit(int)} is called with this value.
	 * 
	 * @param t
	 *            throwable to manage.
	 * @param exitValue
	 *            the exit value (-1 to ignore).
	 */
	public static final void manageThrowable(final Throwable t, final int exitValue) {
		// Shows stack trace only in verbose mode.
		if (VERBOSE_LEVEL.intValue() <= Level.FINE.intValue()) {
			t.printStackTrace();
		}

		if (exitValue != -1) {
			System.exit(exitValue);
		}
	}

}
