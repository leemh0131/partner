package com.ensys.qray.fi.notice;

import lombok.RequiredArgsConstructor;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static com.chequer.axboot.core.utils.HttpUtils.getRemoteAddress;
import static com.ensys.qray.utils.HammerUtility.nowDate;
import static java.util.Arrays.*;
import static org.apache.poi.ss.usermodel.CellType.*;
import static org.apache.poi.ss.usermodel.Row.MissingCellPolicy.CREATE_NULL_AS_BLANK;
import static org.springframework.util.StringUtils.*;

@Service
@Transactional
@RequiredArgsConstructor
public class FiNotice01ExcelService {

    private final FiNotice01Mapper fiNotice01Mapper;

    public HashMap<String, Object> excelUpload(MultipartFile excelFile) throws IOException {
        HashMap<String, Object> result = new HashMap<>();
        String excelFileName = excelFile.getOriginalFilename();

        int fileNameExtensionIndex = excelFileName.lastIndexOf('.') + 1;
        String fileNameExtension = excelFileName.toLowerCase().substring(fileNameExtensionIndex,
                excelFileName.length());

        if (fileNameExtension == null) {
            throw new RuntimeException("파일이 없습니다. 다시 업로드 해주세요");
        }
        List<String> columns1 = asList("DM_CD", "DM_TYPE", "DM_KIND", "COMP_NM", "BORW_SITE"
                , "DEBTOR_TEL", "DEBTOR_KAKAO", "DEBTOR_TELE", "DEBTOR_SNS", "COMPL_POLICE", "WITHDR_LOCA", "DM_CONTENTS");
        List<String> columns2 = asList("BANK_CD", "BANK_NM", "NO_DEPOSIT", "NM_DEPOSITOR");
        Workbook workbook = null;
        try {
            if ("xls".equals(fileNameExtension)) {
                workbook = new HSSFWorkbook(excelFile.getInputStream());
            } else if ("xlsx".equals(fileNameExtension)) {
                workbook = new XSSFWorkbook(excelFile.getInputStream());
            }
            String nowDate = nowDate("yyyyMMddHHmmss");
            Sheet sheet = workbook.getSheetAt(0); // 첫 번째 시트 선택

            int startRow = 8; // 9번째 행부터 시작
            for (int rowNum = startRow; rowNum <= sheet.getLastRowNum(); rowNum++) {
                Row row = sheet.getRow(rowNum);
                HashMap<String, Object> hashMap1 = new HashMap<>();
                List<HashMap<String, Object>> list2 = new ArrayList<>();
                HashMap<String, Object> hashMap2 = new HashMap<>();

                if (row != null) {
                    // A~K 열 처리 (HashMap1)
                    for (int cellNum = 0; cellNum <= 11; cellNum++) {
                        Cell cell = row.getCell(cellNum);

                        if (row.getCell(0, CREATE_NULL_AS_BLANK).getStringCellValue().trim().isEmpty()) {
                            break;
                        }

                        String cellValue = "";
                        if (cell == null) {
                            cellValue = "";
                        } else {
                            if (cell.getCellType() == STRING) {
                                cellValue = cell.getStringCellValue();
                            } else if (cell.getCellType() == NUMERIC) {
                                cell.setCellType(STRING);
                                cellValue = cell.getStringCellValue();
                            } else if (cell.getCellType() == BLANK) {
                                cellValue = "";
                            } else if (cell.getCellType() == BOOLEAN) {
                                cellValue = String.valueOf(cell.getBooleanCellValue());
                            } else {
                                cellValue = "";
                            }
                        }

                        hashMap1.put(columns1.get(cellNum), cellValue);
                    }

                    // L~O, P~S, T~W 열 처리 (HashMap2)
                    for (int cellNum = 12; cellNum <= 22; cellNum += 4) {
                        for (int i = 0; i < 4; i++) {
                            Cell cell = row.getCell(cellNum + i);
                            String cellValue = "";
                            if (cell == null) {
                                cellValue = "";
                            } else {
                                if (cell.getCellType() == STRING) {
                                    cellValue = cell.getStringCellValue();
                                } else if (cell.getCellType() == NUMERIC) {
                                    cell.setCellType(STRING);
                                    cellValue = cell.getStringCellValue();
                                } else if (cell.getCellType() == BLANK) {
                                    cellValue = "";
                                } else if (cell.getCellType() == BOOLEAN) {
                                    cellValue = String.valueOf(cell.getBooleanCellValue());
                                } else {
                                    cellValue = "";
                                }
                            }
                            hashMap2.put(columns2.get(i), cellValue);
                        }
                        list2.add(hashMap2);
                    }
                }
                if (!hashMap1.isEmpty()) {
                    hashMap1.put("WRITE_DATE", nowDate);
                    hashMap1.put("WRITE_IP", getRemoteAddress());
                    hashMap1.put("INSERT_DATE", nowDate);
                    hashMap1.put("UPDATE_DATE", nowDate);
                    hashMap1.put("USE_YN", "Y");
                    result.put("DM_CD", hashMap1.get("DM_CD"));
                    String dmType = (String) hashMap1.get("DM_TYPE");
                    if (!hasText(dmType)) {
                        hashMap1.put("DM_TYPE", "001");
                    }
                    int created = fiNotice01Mapper.created(hashMap1);
                    if (!list2.isEmpty() && created == 1) {
                        for (HashMap<String, Object> item2 : list2) {
                            item2.put("DM_CD", hashMap1.get("DM_CD"));
                            item2.put("USE_YN", "Y");
                            item2.put("INSERT_DATE", nowDate);
                            item2.put("UPDATE_DATE", nowDate);
                            fiNotice01Mapper.createdPlDmDeposit(item2);
                        }
                    }
                }
            }
        } catch (RuntimeException | IOException e) {
            throw new RuntimeException(e);
        } finally {
            if (workbook != null) {
                workbook.close();
            }
        }
        return result;
    }
}
