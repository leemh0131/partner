package com.ensys.qray.utils;

import org.apache.commons.collections.map.ListOrderedMap;
import org.apache.commons.lang.StringUtils;

public class UpperMap extends ListOrderedMap {

	private static final long serialVersionUID = -7700790403928325865L;

    public Object put(Object key , Object value) {
        return super.put(StringUtils.upperCase((String) key), value);
    }
}
