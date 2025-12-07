package com.ensys.qray.file;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.HammerUtility;
import com.ensys.qray.utils.SessionUtils;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.Rectangle;
import com.lowagie.text.*;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import fr.opensagres.poi.xwpf.converter.pdf.PdfConverter;
import fr.opensagres.poi.xwpf.converter.pdf.PdfOptions;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.io.Resources;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.ImageType;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.apache.pdfbox.tools.imageio.ImageIOUtil;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hwpf.HWPFDocument;
import org.apache.poi.hwpf.extractor.WordExtractor;
import org.apache.poi.hwpf.usermodel.Range;
import org.apache.poi.openxml4j.opc.OPCPackage;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.xslf.usermodel.XMLSlideShow;
import org.apache.poi.xslf.usermodel.XSLFSlide;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import java.awt.*;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.*;
import java.nio.ByteBuffer;
import java.nio.channels.GatheringByteChannel;
import java.nio.channels.ScatteringByteChannel;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.*;

import static com.ensys.qray.file.FileSupport.getGlobalFilePath;
import static java.util.UUID.*;

@Service
@Transactional
@RequiredArgsConstructor
public class FileService extends BaseService {

	public final FileMapper fileMapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> search(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return fileMapper.search(param);
	}

	public void save(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		List<HashMap<String, Object>> saveData = (List<HashMap<String, Object>>) param.get("saveData");
		String filePath = FileSupport.getGlobalFilePath();

		if (saveData != null && saveData.size() > 0) {
			for (HashMap<String, Object> item : saveData) {
				if (item != null && item.size() > 0) {

					item.put("COMPANY_CD", user.getCompanyCd());
					item.put("INSERT_ID", user.getUserId());
					item.put("UPDATE_ID", user.getUserId());
					item.put("INSERT_DTS", strDate);
					item.put("UPDATE_DTS", strDate);

					if (item.get("__deleted__") != null) {
						if ((boolean) item.get("__deleted__")) {
							fileMapper.delete(item);
						}
					} else if (item.get("__created__") != null) {
						if ((boolean) item.get("__created__")) {
							item.put("FILE_PATH", filePath);
							fileMapper.insert(item);
						}
					}
				}
			}
		}
	}

	public void update(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		HashMap<String, Object> saveData = (HashMap<String, Object>) param.get("saveData");

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)saveData.get("updated")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("INSERT_ID", user.getUserId());
			item.put("UPDATE_ID", user.getUserId());
			item.put("INSERT_DTS", strDate);
			item.put("UPDATE_DTS", strDate);
			fileMapper.updated(item);
		}


	}

	/** 메일보내드 첨부파일 업로드
	 *  서버에 파일 저장 후 DB 저장
	 *  return DB에 저장된 key List 반환
	 */
	public List<HashMap<String, Object>> mailUpload(MultipartFile[] mf, String tableId, String tableKey) throws Exception {

		List<HashMap<String, Object>> result = new ArrayList<>();
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		try {
			//파일경로
			Reader reader = Resources.getResourceAsReader("axboot-local.properties");
			Properties properties = new Properties();
			properties.load(reader);
			String filePath = "";
			/* OS확인  */
			String os = System.getProperty("os.name").toLowerCase();
			if(os.contains("windows")){
				filePath = properties.getProperty("FILE_DIRECTORY_PATH_WINDOWS");
			}else if(os.contains("linux")){
				filePath = properties.getProperty("FILE_DIRECTORY_PATH");
			};

			if (filePath != null && !"".equals(filePath) && !"null".equals(filePath)) {
				File dir = new File(filePath);

				/* 폴더가 없을 경우 생성 */
				if (!dir.isDirectory()) {
					dir.mkdir();
				}
			}

			if(!"".equals(tableKey) && tableKey != null && !"null".equals(tableKey)){
				int fileSeq = 0;
				if (mf != null && mf.length > 0) {
					for (int i = 0; i < mf.length; i++) {
						HashMap<String, Object> map = new HashMap<>();
						String savedFileNm = randomUUID().toString(); //서버에 저장될 파일 이름
						String fileExtension = ext(mf[i].getOriginalFilename());
						map.put("FILE_SEQ", fileSeq++);
						map.put("TABLE_ID", tableId);
						map.put("TABLE_KEY", tableKey);
						map.put("FILE_NAME", savedFileNm);
						map.put("ORGN_FILE_NAME", mf[i].getOriginalFilename());
						map.put("FILE_PATH", filePath);
						map.put("FILE_EXT", fileExtension);
						map.put("FILE_BYTE", mf[i].getSize());
						map.put("FILE_SIZE", String.valueOf(mf[i].getSize()));
						map.put("FILE_DIVISION", 0);
						map.put("COMPANY_CD", user.getCompanyCd());
						map.put("INSERT_ID", user.getUserId());
						map.put("INSERT_DTS", strDate);
						map.put("UPDATE_ID", user.getUserId());
						map.put("UPDATE_DTS", strDate);
						map.put("SERVER_KEY", "ensys");
						fileMapper.delete(map);
						fileMapper.insert(map);
						result.add(map);

						File file = new File(filePath + "\\" + savedFileNm + "." + fileExtension);
						mf[i].transferTo(file);
					}
				}
			}
		} catch (Exception e){
			e.printStackTrace();
		}

		return result;
	}

	//파일뷰어업로드
	public List<HashMap<Object, Object>> fileUpload(List<MultipartFile> mf, List<HashMap<String, Object>> fileName)
			throws Exception {
		SessionUser user = SessionUtils.getCurrentUser();

		//파일경로
		Reader reader = Resources.getResourceAsReader("axboot-local.properties");
		Properties properties = new Properties();
		properties.load(reader);
		String filePath = properties.getProperty("FILE_DIRECTORY_PATH_WINDOWS");

		List<HashMap<Object, Object>> result = new ArrayList<>();
		if (filePath != null) {
			File dir = new File(filePath);

			/* 폴더가 없을 경우 생성 */
			if (!dir.isDirectory()) {
				dir.mkdir();
			}
		}

		if (mf != null && mf.size() > 0) {
			for (int i = 0; i < mf.size(); i++) {
				String savedFileNm = (String) fileName.get(i).get("FILE_NAME");
				String fileExtension = (String) fileName.get(i).get("FILE_EXT");

				File file = new File(filePath + "\\" + savedFileNm + "." + fileExtension);
				mf.get(i).transferTo(file);

				//int divisionCnt = msFileToImage(file, savedFileNm, filePath);
				HashMap<Object, Object> resultMap = new HashMap<>();
				resultMap.put(Integer.parseInt((String) fileName.get(i).get("FILE_SEQ")), 0);
				result.add(resultMap);

			}
		}
		HashMap<Object, Object> item = new HashMap<>();
		item.put("FILE_PATH", filePath);
		result.add(item);
		return result;
	}

	private static String ext(String fileName) {
		int fileNameExtensionIndex = fileName.lastIndexOf('.') + 1;
		if (fileNameExtensionIndex == 0) {
			return "";
		}
		String fileNameExtension = fileName.toLowerCase().substring(fileNameExtensionIndex, fileName.length());
		return fileNameExtension;
	}

	public static void main(String[] args) {
		int result = 0;
		try {
		result = msFileToImage(new File("D:\\test\\test.xls"), "kangmin", "D:\\test");
		System.out.println("msFileToImage  : " +  result);
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public static int msFileToImage(File savefile, String fileName, String path) throws Exception {
		InputStream docFile = new FileInputStream(savefile);
		String PDFFILE = path + "\\" + fileName + ".pdf";
		int divisionCnt = 0;
		if (exe(savefile.getName()).equals("pptx") || exe(savefile.getName()).equals("ppt")) {
			System.out.println("[ **** PPT 변환 시작 **** ]");

			XMLSlideShow ppt = new XMLSlideShow(OPCPackage.open(docFile));
			Dimension pgsize = ppt.getPageSize();
			float scale = 1;
			int width = (int) (pgsize.width * scale);
			int height = (int) (pgsize.height * scale);
			int i = 0;
			int totalSlides = ppt.getSlides().size();
			for (XSLFSlide slide : ppt.getSlides()) {
				BufferedImage img = new BufferedImage(pgsize.width, pgsize.height, BufferedImage.TYPE_INT_RGB);
				Graphics2D graphics = img.createGraphics();
				graphics.setPaint(Color.white);
				graphics.fill(new Rectangle2D.Float(0, 0, pgsize.width, pgsize.height));
				graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
				graphics.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
				graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
				graphics.setRenderingHint(RenderingHints.KEY_FRACTIONALMETRICS,
						RenderingHints.VALUE_FRACTIONALMETRICS_ON);
				graphics.setColor(Color.white);
				graphics.clearRect(0, 0, width, height);
				graphics.scale(scale, scale);
				slide.draw(graphics);
				FileOutputStream out = new FileOutputStream(path + "\\" + fileName + "_" + i + ".png");
				ImageIO.write(img, "png", out);
				out.close();
				i++;
			}
			divisionCnt = i;
			Document document = new Document();
			PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream(new File(PDFFILE)));
			document.open();
			writer.setPageEmpty(true);
			for (int j = 0; j < totalSlides; j++) {
				Image slideImage = Image.getInstance(path + "\\" + fileName + "_" + j + ".png");

				document.setPageSize(new Rectangle(slideImage.getWidth(), slideImage.getHeight()));

				document.newPage();
				writer.setPageEmpty(true);
				slideImage.setAbsolutePosition(0, 0);

				document.add(slideImage);
			}
			document.close();
			System.out.println("[ **** PPT 변환 종료 **** ]");
		} else if (exe(savefile.getName()).equals("xlsx")) {
			System.out.println("[ **** 엑셀xlsx 변환 시작 **** ]");
			Document document = new Document();
			OutputStream file = new FileOutputStream(new File(PDFFILE));
			PdfWriter writer = PdfWriter.getInstance(document, file);
			document.open();
			writer.setPageEmpty(true);

			XSSFWorkbook workbook = new XSSFWorkbook(docFile);
			int sheetCnt = workbook.getNumberOfSheets();

			List<Integer> maxCell = new ArrayList<Integer>();

			for (int sc = 0; sc < sheetCnt; sc++) {
				int maxCellCnt = 0;
				XSSFSheet sheet = workbook.getSheetAt(sc);
				int rows = sheet.getLastRowNum();

				for (int rowindex = 0; rowindex < rows; rowindex++) {
					XSSFRow row = sheet.getRow(rowindex);
					if (row != null) {
						if (maxCellCnt < row.getLastCellNum()) {
							maxCellCnt = row.getLastCellNum();
						}
					}
				}
				maxCell.add(maxCellCnt);
			}
			for (int sc = 0; sc < sheetCnt; sc++) {

				document.newPage();
				writer.setPageEmpty(true);

				XSSFSheet sheet = workbook.getSheetAt(sc); // 행의 수
				int rows = sheet.getLastRowNum();

				PdfPTable my_table = new PdfPTable(maxCell.get(sc));
				BaseFont bf = BaseFont.createFont("HYSMyeongJo-Medium", "UniKS-UCS2-H", BaseFont.NOT_EMBEDDED);
				Font font = new Font(bf, 9, Font.NORMAL);

				for (int rowindex = 0; rowindex < rows; rowindex++) {
					XSSFRow row = sheet.getRow(rowindex);
					if (row != null) {
						for (int columnindex = 0; columnindex < maxCell.get(sc); columnindex++) { // 셀값을 읽는다
							XSSFCell cell = row.getCell(columnindex);

							String cellValue = "";
							if (cell == null) {
								cellValue = "";
							} else {
								if (cell.getCellType() == CellType.STRING) {
									cellValue = cell.getStringCellValue();
								} else if (cell.getCellType() == CellType.NUMERIC) {
									cell.setCellType(CellType.STRING);
									cellValue = cell.getStringCellValue();
								} else if (cell.getCellType() == CellType.BLANK) {
									cellValue = "";
								} else if (cell.getCellType() == CellType.BOOLEAN) {
									cellValue = String.valueOf(cell.getBooleanCellValue());
								}
							}
							System.out.println(
									"rowindex : " + rowindex + ", columnindex : " + columnindex + ", " + cellValue);

							my_table.addCell(new PdfPCell(new Phrase(cellValue, font)));
						}
					} else {
						for (int columnindex = 0; columnindex < maxCell.get(sc); columnindex++) {
							my_table.addCell(new PdfPCell(new Phrase("", font)));
						}
					}
				}
				document.add(my_table);
			}

			document.close();
			file.close();

			InputStream pdfFile = new FileInputStream(new File(PDFFILE));

			PDDocument pdfDoc = PDDocument.load(pdfFile); // Document 생성
			PDFRenderer pdfRenderer = new PDFRenderer(pdfDoc);
			Files.createDirectories(Paths.get(path));

			for (int i = 0; i < pdfDoc.getPages().getCount(); i++) {
				String imgFileName = path + "\\" + fileName + "_" + i + ".png";
				BufferedImage bim = pdfRenderer.renderImageWithDPI(i, 300, ImageType.RGB);
				ImageIOUtil.writeImage(bim, imgFileName, 300);
			}
			divisionCnt = pdfDoc.getPages().getCount();

			pdfDoc.close(); // 모두 사용한 PDF 문서는 닫는다.
			System.out.println("[ **** 엑셀xlsx 변환 종료 **** ]");
		} else if (exe(savefile.getName()).equals("xls")) {
			System.out.println("[ **** 엑셀xls 변환 시작 **** ]");
			Document document = new Document();
			OutputStream file = new FileOutputStream(new File(PDFFILE));
			PdfWriter writer = PdfWriter.getInstance(document, file);
			document.open();
			writer.setPageEmpty(true);

			HSSFWorkbook workbook = new HSSFWorkbook(docFile);
			int sheetCnt = workbook.getNumberOfSheets();

			List<Integer> maxCell = new ArrayList<Integer>();

			for (int sc = 0; sc < sheetCnt; sc++) {
				int maxCellCnt = 0;
				HSSFSheet sheet = workbook.getSheetAt(sc);
				int rows = sheet.getLastRowNum();

				for (int rowindex = 0; rowindex < rows; rowindex++) {
					HSSFRow row = sheet.getRow(rowindex);
					if (row != null) {
						if (maxCellCnt < row.getLastCellNum()) {
							maxCellCnt = row.getLastCellNum();
						}
					}
				}
				maxCell.add(maxCellCnt);
			}
			for (int sc = 0; sc < sheetCnt; sc++) {

				document.newPage();
				writer.setPageEmpty(true);

				HSSFSheet sheet = workbook.getSheetAt(sc); // 행의 수
				int rows = sheet.getLastRowNum();

				PdfPTable my_table = new PdfPTable(maxCell.get(sc));
				BaseFont bf = BaseFont.createFont("HYSMyeongJo-Medium", "UniKS-UCS2-H", BaseFont.NOT_EMBEDDED);
				Font font = new Font(bf, 9, Font.NORMAL);

				for (int rowindex = 0; rowindex < rows; rowindex++) {
					HSSFRow row = sheet.getRow(rowindex);
					if (row != null) {
						for (int columnindex = 0; columnindex < maxCell.get(sc); columnindex++) { // 셀값을 읽는다
							HSSFCell cell = row.getCell(columnindex);

							String cellValue = "";
							if (cell == null) {
								cellValue = "";
							} else {
								if (cell.getCellType() == CellType.STRING) {
									cellValue = cell.getStringCellValue();
								} else if (cell.getCellType() == CellType.NUMERIC) {
									cell.setCellType(CellType.STRING);
									cellValue = cell.getStringCellValue();
								} else if (cell.getCellType() == CellType.BLANK) {
									cellValue = "";
								} else if (cell.getCellType() == CellType.BOOLEAN) {
									cellValue = String.valueOf(cell.getBooleanCellValue());
								}
							}
							System.out.println(
									"rowindex : " + rowindex + ", columnindex : " + columnindex + ", " + cellValue);

							my_table.addCell(new PdfPCell(new Phrase(cellValue, font)));
						}
					} else {
						for (int columnindex = 0; columnindex < maxCell.get(sc); columnindex++) {
							my_table.addCell(new PdfPCell(new Phrase("", font)));
						}
					}
				}
				document.add(my_table);
			}

			document.close();
			file.close();

			InputStream pdfFile = new FileInputStream(new File(PDFFILE));

			PDDocument pdfDoc = PDDocument.load(pdfFile); // Document 생성
			PDFRenderer pdfRenderer = new PDFRenderer(pdfDoc);
			Files.createDirectories(Paths.get(path));

			for (int i = 0; i < pdfDoc.getPages().getCount(); i++) {
				String imgFileName = path + "\\" + fileName + "_" + i + ".png";
				BufferedImage bim = pdfRenderer.renderImageWithDPI(i, 300, ImageType.RGB);
				ImageIOUtil.writeImage(bim, imgFileName, 300);
			}
			divisionCnt = pdfDoc.getPages().getCount();
			pdfDoc.close(); // 모두 사용한 PDF 문서는 닫는다.
			System.out.println("[ **** 엑셀xls 변환 종료 **** ]");
		} else if (exe(savefile.getName()).equals("doc")) {
			Document document = new Document();
			OutputStream file = new FileOutputStream(new File(PDFFILE));
			PdfWriter writer = PdfWriter.getInstance(document, file);
			document.open();
			writer.setPageEmpty(true);

			System.out.println("[ **** 워드doc 변환 시작 **** ]");
			POIFSFileSystem fs = new POIFSFileSystem(docFile);
			HWPFDocument doc = new HWPFDocument(fs);
			WordExtractor we = new WordExtractor(doc);

			Range range = doc.getRange();
			document.open();
			writer.setPageEmpty(true);
			document.newPage();
			writer.setPageEmpty(true);

			String[] paragraphs = we.getParagraphText();
			for (int i = 0; i < paragraphs.length; i++) {

				org.apache.poi.hwpf.usermodel.Paragraph pr = range.getParagraph(i);
				paragraphs[i] = paragraphs[i].replaceAll("\\cM?\r?\n", "");
				document.add(new Paragraph(paragraphs[i]));

			}

			document.close();
			file.close();

			InputStream pdfFile = new FileInputStream(new File(PDFFILE));

			PDDocument pdfDoc = PDDocument.load(pdfFile); // Document 생성
			PDFRenderer pdfRenderer = new PDFRenderer(pdfDoc);
			Files.createDirectories(Paths.get(path));

			for (int i = 0; i < pdfDoc.getPages().getCount(); i++) {
				String imgFileName = path + "\\" + fileName + "_" + i + ".png";
				BufferedImage bim = pdfRenderer.renderImageWithDPI(i, 300, ImageType.RGB);
				ImageIOUtil.writeImage(bim, imgFileName, 300);
			}
			divisionCnt = pdfDoc.getPages().getCount();
			pdfDoc.close(); // 모두 사용한 PDF 문서는 닫는다.

			System.out.println("[ **** 워드doc 변환 종료 **** ]");
		} else if (exe(savefile.getName()).equals("docx")) {

			System.out.println("[ **** 워드docx 변환 시작 **** ]");
			OutputStream file = new FileOutputStream(new File(PDFFILE));
			XWPFDocument doc = new XWPFDocument(docFile);
			PdfOptions pdfOptions = PdfOptions.create();

			PdfConverter.getInstance().convert(doc, file, pdfOptions);
			doc.close();
			file.close();

			InputStream pdfFile = new FileInputStream(new File(PDFFILE));

			PDDocument pdfDoc = PDDocument.load(pdfFile); // Document 생성
			PDFRenderer pdfRenderer = new PDFRenderer(pdfDoc);
			Files.createDirectories(Paths.get(path));

			for (int i = 0; i < pdfDoc.getPages().getCount(); i++) {
				String imgFileName = path + "\\" + fileName + "_" + i + ".png";
				BufferedImage bim = pdfRenderer.renderImageWithDPI(i, 300, ImageType.RGB);
				ImageIOUtil.writeImage(bim, imgFileName, 300);
			}
			divisionCnt = pdfDoc.getPages().getCount();
			pdfDoc.close(); // 모두 사용한 PDF 문서는 닫는다.
			System.out.println("[ **** 워드docx 변환 종료 **** ]");
		} else if (exe(savefile.getName()).equals("pdf")) {
			System.out.println("[ **** pdf 변환 시작 **** ]");

			PDDocument pdfDoc = PDDocument.load(docFile); // Document 생성
			PDFRenderer pdfRenderer = new PDFRenderer(pdfDoc);
			Files.createDirectories(Paths.get(path));

			for (int i = 0; i < pdfDoc.getPages().getCount(); i++) {
				String imgFileName = path + "\\" + fileName + "_" + i + ".png";
				BufferedImage bim = pdfRenderer.renderImageWithDPI(i, 300, ImageType.RGB);
				ImageIOUtil.writeImage(bim, imgFileName, 300);
			}
			divisionCnt = pdfDoc.getPages().getCount();
			pdfDoc.close(); // 모두 사용한 PDF 문서는 닫는다.
			System.out.println("[ **** pdf 변환 종료 **** ]");
		}
		docFile.close();
		return divisionCnt;
	}

	// 파일복사
	public void copyFile(HashMap<String, Object> file, String MODULE, String CD_FILE) {
		// 원본 파일경로
		String oriFilePath = file.get("FILE_PATH") + "\\" + file.get("FILE_NAME");
		File oriFile = new File(oriFilePath);

		File copyFolder0 = new File("D:\\ERP-U\\Upload\\"); // 복사될 폴더
		/* 폴더가 없을 경우 생성 */
		if (!copyFolder0.isDirectory()) {
			copyFolder0.mkdir();
		}

		File copyFolder = new File("D:\\ERP-U\\Upload\\" + CD_FILE); // 복사될 폴더
		// * 폴더가 없을 경우 생성*//*
		if (!copyFolder.isDirectory()) {
			copyFolder.mkdir();
		}

		try {

			FileInputStream fis = new FileInputStream(oriFile); // 읽을파일
			FileOutputStream fos = new FileOutputStream(copyFolder + "\\" + file.get("ORGN_FILE_NAME")); // 복사할파일

			ScatteringByteChannel sbc = fis.getChannel();
			GatheringByteChannel gbc = fos.getChannel();

			ByteBuffer bb = ByteBuffer.allocateDirect(1024);

			while (sbc.read(bb) != -1) {
				bb.flip();
				gbc.write(bb);
				bb.clear();
			}
			// 자원사용종료
			fis.close();
			fos.close();

		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return;
		} catch (IOException e) {
			e.printStackTrace();
			return;
		}
	}

	private static String exe(String fileName) {
		int fileNameExtensionIndex = fileName.lastIndexOf('.') + 1;
		String fileNameExtension = fileName.toLowerCase().substring(fileNameExtensionIndex, fileName.length());
		return fileNameExtension;
	}

	@Transactional
	public void bannerUpload(MultipartFile[] bannerImage,String device) throws Exception {

		MultipartFile file = bannerImage[0];
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");
		SessionUser user = SessionUtils.getCurrentUser();

		HashMap<String, Object> param = new HashMap<>();
		param.put("COMPANY_CD", user.getCompanyCd());

		String FILE_NAME = "";

		if("pc".equals(device)){
			param.put("TABLE_ID", "CENTER_BANNER_PC");
			param.put("TABLE_KEY", "CENTER_BANNER_PC");
			FILE_NAME = "center_banner_img_pc";
		} else {
			param.put("TABLE_ID", "CENTER_BANNER_MO");
			param.put("TABLE_KEY", "CENTER_BANNER_MO");
			FILE_NAME = "center_banner_img_mo";
		}

		param.put("FILE_SEQ", "1");


		String filePath = FileSupport.getGlobalFilePath();

		fileMapper.delete(param);

		param.put("FILE_PATH", filePath);

		// 파일 이름 가져오기
		String originalFilename = file.getOriginalFilename();
		param.put("ORGN_FILE_NAME", originalFilename);

		// 확장자 가져오기
		String fileExtension = "";
		if (originalFilename != null) {
			int lastDotIndex = originalFilename.lastIndexOf(".");
			if (lastDotIndex != -1) {
				fileExtension = originalFilename.substring(lastDotIndex + 1);
			}
		}
		param.put("FILE_EXT", fileExtension);
		param.put("FILE_NAME", FILE_NAME);

		param.put("INSERT_ID", user.getUserId());
		param.put("INSERT_DTS", strDate);
		param.put("UPDATE_ID", user.getUserId());
		param.put("UPDATE_DTS", strDate);

		fileMapper.insert(param);

		if (filePath != null) {
			File dir = new File(filePath);

			 //폴더가 없을 경우 생성
			if (!dir.isDirectory()) {
				dir.mkdir();
			}

			File newFile = new File(filePath + File.separator + FILE_NAME + "." + fileExtension);

			if(newFile.isFile()){
				newFile.delete();
			}

			file.transferTo(newFile);

			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
			String savePath = request.getSession().getServletContext().getRealPath("/file");
			if("jpg".equals(param.get("FILE_EXT")) || "png".equals(param.get("FILE_EXT")) || "gif".equals(param.get("FILE_EXT")) || "pdf".equals(param.get("FILE_EXT"))){
				File chkFile = new File(savePath + File.separator + param.get("FILE_NAME") + "." + param.get("FILE_EXT"));

				if(chkFile.isFile()){
					chkFile.delete();
				}

				File OrgnFile = new File(param.get("FILE_PATH") + File.separator + param.get("FILE_NAME") + "." + param.get("FILE_EXT"));

				if (OrgnFile.isFile()) {
					File copyFolder = new File(savePath);

					if (!copyFolder.isDirectory()) {
						copyFolder.mkdir();
					}

					FileInputStream fis = new FileInputStream(OrgnFile); // 읽을파일
					FileOutputStream fos = new FileOutputStream(savePath + File.separator + param.get("FILE_NAME") + "." + param.get("FILE_EXT")); // 복사할파일
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

    public void simpleFileUpload(MultipartFile file, HashMap<String, Object> param) throws IOException {
        param.put("FILE_NAME", randomUUID().toString());
        param.put("ORGN_FILE_NAME", file.getOriginalFilename());
        param.put("FILE_BYTE", file.getSize());
        param.put("FILE_PATH", getGlobalFilePath());

        File destination = new File(getGlobalFilePath(), (String) param.get("FILE_NAME"));

        if (!destination.getParentFile().exists()) {
            destination.getParentFile().mkdirs();
        }

        file.transferTo(destination);
        fileMapper.insert(param);
    }
}
