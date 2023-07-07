package com.chequer.axboot.core.api.response;

import com.chequer.axboot.core.json.Views;
import com.chequer.axboot.core.vo.PageableVO;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonView;
import com.wordnik.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Responses {

    @Data
    @NoArgsConstructor
    @RequiredArgsConstructor(staticName = "of")
    public static class ListResponse {

        @JsonView(Views.Root.class)
        @JsonProperty("list")
        @NonNull
        @ApiModelProperty(value = "목록", required = true)
        List<?> list;

        @NonNull
        @ApiModelProperty(value = "페이징 정보", required = true)
        @JsonView(Views.Root.class)
        PageableVO page = PageableVO.of(0, 0L, 0, 0);
    }

    @Data
    public static class MapResponse {
        private Map<String, Object> map;

        private MapResponse(Map<String, Object> map) {
            this.map = map;
        }

        @ApiModelProperty(value = "Map", required = true)
        @JsonProperty("map")
        @JsonView(Views.Root.class)
        public static MapResponse of(Map<String, Object> map) {
            return new MapResponse(map);
        }
    }

    /*@Data
    @NoArgsConstructor
    @RequiredArgsConstructor(staticName = "of")
    public static class MapResponse {

        @NonNull
        @ApiModelProperty(value = "Map", required = true)
        @JsonProperty("map")
        @JsonView(Views.Root.class)
        Map<String, Object> map;
    }*/

    @Data
    @NoArgsConstructor
    public static class PageResponse {
        @NonNull
        @JsonProperty("list")
        @JsonView(Views.Root.class)
        List<?> list;

        @NonNull
        @JsonView(Views.Root.class)
        PageableVO page;

        public static PageResponse of(List<?> content, Page<?> page) {
            PageResponse pageResponse = new PageResponse();
            pageResponse.setList(content);
            pageResponse.setPage(PageableVO.of(page));
            return pageResponse;
        }

        public static PageResponse of(List<?> content, HashMap<String, Integer> page) {
            PageResponse pageResponse = new PageResponse();
            pageResponse.setList(content);

            if(content.size() > 0 && content != null){
                int totalCount = ((Number)((HashMap) content.get(0)).get("TOT_CNT")).intValue();
                int pageSize = page.get("pageSize");
                int lastPageLot = totalCount / pageSize;
                int lastPageRemainder = totalCount % pageSize;
                if(lastPageRemainder != 0) {
                    lastPageLot++;
                }

                page.put("totalElements", totalCount);
                page.put("totalPages", lastPageLot);
            } else {
                page.put("totalElements", 0);
                page.put("totalPages", 0);
            }

            pageResponse.setPage(PageableVO.of(
                    page.get("totalPages"),
                    ((Number) page.get("totalElements")).longValue(),
                    page.get("currentPage"),
                    page.get("pageSize")
                )
            );
            return pageResponse;
        }

        public static PageResponse of(Page<?> page) {
            return of(page.getContent(), page);
        }
    }
}
