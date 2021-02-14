from datetime import datetime
from datetime import timedelta

def timestamp_format(d):
    """
    translates :class:`datetime` `d` to a "sup-style" human readable string.
    >>> now = datetime.now()
    >>> now.strftime('%c')
    'Sat 31 Mar 2012 14:47:26 '
    >>> timestamp_format(now)
    u'just now'
    >>> timestamp_format(now - timedelta(minutes=1))
    u'1min ago'
    >>> timestamp_format(now - timedelta(hours=5))
    u'5h ago'
    >>> timestamp_format(now - timedelta(hours=12))
    u'02:54'
    >>> timestamp_format(now - timedelta(days=1))
    u'yest 14h'
    >>> timestamp_format(now - timedelta(days=2))
    u'Thu 14h'
    >>> timestamp_format(now - timedelta(days=7))
    u'24 Mar'
    >>> timestamp_format(now - timedelta(days=356))
    u'Apr 2011'
    """
    hourfmt = '%Hh'
    hourminfmt = '%H:%M'

    now = datetime.now()
    today = now.date()
    if d.date() == today or d > now - timedelta(hours=6):
        delta = datetime.now() - d
        if delta.seconds < 60:
            string = 'just now'
        elif delta.seconds < 3600:
            string = '%dmin ago' % (delta.seconds // 60)
        elif delta.seconds < 6 * 3600:
            string = '%dh ago' % (delta.seconds // 3600)
        else:
            string = d.strftime(hourminfmt)
    elif d.date() == today - timedelta(1):
        string = d.strftime('yest ' + hourfmt)
    elif d.date() > today - timedelta(7):
        string = d.strftime('%a ' + hourfmt)
    elif d.year != today.year:
        string = d.strftime('%b %Y')
    else:
        string = d.strftime
    return string
