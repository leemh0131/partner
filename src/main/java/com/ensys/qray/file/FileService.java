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
        param.put("FILE_SEQ", 0);

        File destination = new File(getGlobalFilePath(), (String) param.get("FILE_NAME"));

        if (!destination.getParentFile().exists()) {
            destination.getParentFile().mkdirs();
        }

        file.transferTo(destination);
        fileMapper.insert(param);
    }

	public List<HashMap<String, Object>> simpleSearch(HashMap<String, Object> param) {
		return fileMapper.search(param);
	}
}
