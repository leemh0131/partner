package com.ensys.qray.file;

import com.chequer.axboot.core.api.response.ApiResponse;
import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;
import lombok.RequiredArgsConstructor;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.net.URLEncoder;
import java.nio.ByteBuffer;
import java.nio.channels.GatheringByteChannel;
import java.nio.channels.ScatteringByteChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@Controller
@RequiredArgsConstructor
@RequestMapping(value = "/api/file")
public class FileController extends BaseController {

	private final FileService fileService;
	private final LinuxFileService linuxFileService;

	@RequestMapping(value = "search", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse search(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(fileService.search(param));
	}

	@RequestMapping(value = "searchIn", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse searchIn(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(fileService.searchIn(param));
	}

	@RequestMapping(value = "save", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public ApiResponse save(@RequestBody HashMap<String, Object> param) {
		fileService.save(param);
		return ok();
	}

	@ResponseBody
	@RequestMapping(value = "fileUpload", method = { RequestMethod.POST }, produces = APPLICATION_JSON)
	public List<HashMap<Object, Object>> save(@RequestPart("files") List<MultipartFile> images,
			@RequestPart("fileName") List<HashMap<String, Object>> fileName) throws Exception {
		String os = System.getProperty("os.name").toLowerCase();
		if(os.contains("win")) {
			return fileService.fileUpload(images, fileName);
		}else{
			return linuxFileService.fileUpload(images, fileName);
		}
	}

	@RequestMapping(value = "update", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public ApiResponse update(@RequestBody HashMap<String, Object> param) {
		fileService.update(param);
		return ok();
	}

	@RequestMapping(value = "show", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public void show(HttpServletRequest request, @RequestBody HashMap<String, Object> param) throws Exception {
		String FILE_PATH = request.getSession().getServletContext().getRealPath("/file");

		/** jpg, png, gif, pdf 미리보기
		 *  root/webapp 폴더안에 file 라는 폴더를 생성해 그 안에 이미지를 복사해서 보여준다.
		 *
		 */
		if("jpg".equals(param.get("FILE_EXT")) || "png".equals(param.get("FILE_EXT")) || "gif".equals(param.get("FILE_EXT")) || "pdf".equals(param.get("FILE_EXT"))){
			File chkFile = new File(FILE_PATH + File.separator + param.get("FILE_NAME") + "." + param.get("FILE_EXT"));
			if (!chkFile.isFile()) {
				File OrgnFile = new File(param.get("FILE_PATH") + File.separator + param.get("FILE_NAME") + "." + param.get("FILE_EXT"));

				if (OrgnFile.isFile()) {
					File copyFolder = new File(FILE_PATH);

					if (!copyFolder.isDirectory()) {
						copyFolder.mkdir();
					}

					FileInputStream fis = new FileInputStream(OrgnFile); // 읽을파일
					FileOutputStream fos = new FileOutputStream(FILE_PATH + File.separator + param.get("FILE_NAME") + "." + param.get("FILE_EXT")); // 복사할파일
					ScatteringByteChannel sbc = fis.getChannel();
					GatheringByteChannel gbc = fos.getChannel();

					ByteBuffer bb = ByteBuffer.allocateDirect(1024);

					while (sbc.read(bb) != -1) {
						bb.flip();
						gbc.write(bb);
						bb.clear();
					}

					fis.close();
					fos.close();
				}
			}

		}


	}

	@ResponseBody
	@RequestMapping(value = "downloadFile", method = { RequestMethod.POST }, produces = APPLICATION_JSON)
	public void downloadFile(@RequestBody HashMap<String, Object> param, HttpServletRequest request,
			HttpServletResponse response) throws Exception {

		try {

			// 저장경로, 파일이름
			File f = new File(param.get("FILE_PATH") + File.separator + param.get("FILE_NAME") + "." + param.get("FILE_EXT"));

			BufferedInputStream bis = null;
			BufferedOutputStream bos = null;
			byte[] b = new byte[4096];

			int read = 0;

			String fileExtention = (String) param.get("FILE_EXT");

			if (f.isFile()) {
				response.setHeader("Pragma", "no-cache");
				response.setHeader("Accept-Ranges", "bytes");
				response.setHeader("Content-Disposition", "attachment;filename="
						+ URLEncoder.encode((String) param.get("ORGN_FILE_NAME"), "UTF-8") + ";");
				response.setHeader("Content-Transfer-Encoding", "binary;");
				response.setCharacterEncoding("UTF-8");

				switch (fileExtention) {

				case "ppt":
					response.setContentType("application/vnd.ms-powerpoint; charset=utf-8");
					break;

				case "pptx":
					response.setContentType(
							"application/vnd.openxmlformats-officedocument.presentationml.presentation; charset=utf-8");
					break;

				case "xls":
					response.setContentType("application/vnd.ms-excel; charset=utf-8");
					break;

				case "xlsx":
					response.setContentType(
							"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=utf-8");
					break;

				case "doc":
					response.setContentType("application/msword; charset=utf-8");
					break;

				case "docx":
					response.setContentType(
							"application/vnd.openxmlformats-officedocument.wordprocessingml.document; charset=utf-8");
					break;

				case "pdf":
					response.setContentType("application/pdf; charset=utf-8");
					break;

				default:
					response.setContentType("application/octet-stream; charset=utf-8");
					break;

				}
				response.setContentLength((int) f.length());// size setting

				try {

					bis = new BufferedInputStream(new FileInputStream(f));
					bos = new BufferedOutputStream(response.getOutputStream());

					while ((read = bis.read(b)) != -1) {
						bos.write(b, 0, read);
					}

					bis.close();
					bos.flush();
					bos.close();

				} catch (Exception e) {
					e.printStackTrace();
				} finally {

					if (bis != null) {

						bis.close();

					}
				}

			} else {
				System.out.println("파일이 잘못입니다");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	@ResponseBody
	@RequestMapping(value = "/excelUpload", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse excelUpload(@RequestParam("files") MultipartFile excelFile) {
		List<HashMap<String, Object>> result = new ArrayList<HashMap<String, Object>>();

		try {
			XSSFWorkbook workbook = new XSSFWorkbook(excelFile.getInputStream());

			int rowindex = 0;
			int columnindex = 0;
			// 시트 수 (첫번째에만 존재하므로 0을 준다)
			// 만약 각 시트를 읽기위해서는 FOR문을 한번더 돌려준다
			XSSFSheet sheet = workbook.getSheetAt(0);
			// 행의 수
			int rows = sheet.getPhysicalNumberOfRows();

			XSSFRow firstRow = sheet.getRow(0);
			int cells = firstRow.getPhysicalNumberOfCells();
			List<String> code = new ArrayList<String>();
			for (rowindex = 0; rowindex < rows; rowindex++) {
				// 행을읽는다
				XSSFRow row = sheet.getRow(rowindex);
				if (row != null) {
					/*
					 * //셀의 수 int cells = row.getPhysicalNumberOfCells();
					 */
					HashMap<String, Object> resultMap = new HashMap<String, Object>();
					for (columnindex = 0; columnindex <= cells; columnindex++) {
						// 셀값을 읽는다
						XSSFCell cell = row.getCell(columnindex);
						String value = "";
						// 셀이 빈값일경우를 위한 널체크
						if (cell == null) {
							continue;
						} else {

							if (cell.getCellType() == CellType.STRING) {
								value = cell.getStringCellValue();
							} else if (cell.getCellType() == CellType.NUMERIC) {
								cell.setCellType(CellType.STRING);
								value = cell.getStringCellValue();
							} else if (cell.getCellType() == CellType.BLANK) {
								value = "";
							} else if (cell.getCellType() == CellType.BOOLEAN) {
								value = String.valueOf(cell.getBooleanCellValue());
							}
						}
						if (rowindex == 0) {
							break;
						} else if (rowindex == 1) {
							code.add(value);
						} else if (rowindex > 3) { // 0 : 컬럼명, 1 : 컬럼코드, 2: 예제, 3: 안내
							resultMap.put(code.get(columnindex), value);
						}
					}
					if (resultMap.size() > 0) {
						result.add(resultMap);
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return Responses.ListResponse.of(result);
	}

	@ResponseBody
	@RequestMapping(value = "/excelDown", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public void excelDown(HttpServletResponse response, @RequestBody HashMap<String, Object> param) throws Exception {
		try {
			File file = new File(getClass().getResource("/excel/" + param.get("fileName") + ".xlsx").toURI());

			BufferedInputStream bis = null;
			BufferedOutputStream bos = null;
			byte[] b = new byte[4096];
			int read = 0;

			if (file.isFile()) {
				response.setHeader("Pragma", "no-cache");
				response.setHeader("Accept-Ranges", "bytes");
				response.setHeader("Content-Disposition", "attachment;");
				response.setHeader("Content-Transfer-Encoding", "binary;");
				response.setCharacterEncoding("UTF-8");
				response.setContentType("application/vnd.ms-excel; charset=utf-8");
				response.setContentLength((int) file.length());// size setting
				try {
					bis = new BufferedInputStream(new FileInputStream(file));
					bos = new BufferedOutputStream(response.getOutputStream());

					while ((read = bis.read(b)) != -1) {
						bos.write(b, 0, read);
					}
					bis.close();
					bos.flush();
					bos.close();
				} catch (Exception e) {
					e.printStackTrace();
				} finally {
					if (bis != null) {
						bis.close();
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@ResponseBody
	@RequestMapping(value = "bannerUpload", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public ApiResponse draftAttachment(@RequestParam("bannerImage") MultipartFile[] bannerImage, @RequestParam("device") String device) throws Exception {
		fileService.bannerUpload(bannerImage, device);
		return ok();
	}

}
