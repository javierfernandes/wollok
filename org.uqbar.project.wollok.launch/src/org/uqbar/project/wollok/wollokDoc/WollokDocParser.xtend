package org.uqbar.project.wollok.wollokDoc

import com.google.common.base.Charsets
import com.google.common.io.Files
import com.google.inject.Inject
import java.io.BufferedWriter
import java.io.File
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.documentation.impl.MultiLineCommentDocumentationProvider
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.launch.WollokChecker
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * WollokDoc Parser should be called with a single argument:
 * 	the folder where wlk files are located
 * 
 * @author dodain
 */
class WollokDocParser extends WollokChecker {	
	
	val static ES = "es"

	val static HEADER2_ON = "<h3>"
	val static HEADER2_OFF = "</h3>"
	val static HEADER3_ON = "<h4>"
	val static HEADER3_OFF = "</h4>"
	val static HORIZONTAL_LINE = "<hr>"
	val static BOLD_ON = "<b>"
	val static BOLD_OFF = "</b>"
	val static PARAGRAPH_ON = "<p>"
	val static PARAGRAPH_OFF = "</p>"
	val static SPACE = "&nbsp;"
	val static TABLE_ON = "<div class=\"container\"><table class=\"table table-striped table-hover table-sm w-auto\">"
	val static TABLE_OFF = "</table></div>"
	val static TABLE_HEADING_CONF_ON = "<thead>"
	val static TABLE_HEADING_CONF_OFF = "</thread>"
	val static TABLE_BODY_ON = "<tbody>"
	val static TABLE_BODY_OFF = "</tbody>"
	val static TABLE_HEADING_ON = "<th class=\"blue-grey lighten-2\">"
	val static TABLE_HEADING_OFF = "</th>"
	val static TABLE_DATA_ON = "<td width=\"70%;\">"
	val static TABLE_DATA_OFF = "</td>"
	val static TABLE_ROW_ON = "<tr>"
	val static TABLE_ROW_OFF = "</tr>"
	val static LINE_BREAK = "<br>"
	val static CODE_ON = "<code>"
	val static CODE_OFF = "</code>"
	val static wollokDocTokens = #["author", "since", "param", "see", "See", "private", "returns", "return", "throws", "noInstantiate"]
	val static LOCALIZED_COMMENT_SEPARATOR = '''«System.lineSeparator»---«System.lineSeparator»'''
	var BufferedWriter wollokDocFile
	val allFiles = <File>newArrayList
	var String outputFolder
	val LocalDateTime timestamp
	String locale

	@Inject MultiLineCommentDocumentationProvider multilineProvider

	val List<WMethodDeclaration> privateMethods = newArrayList

	new(LocalDateTime timestamp) {
		this.timestamp = timestamp
	}

	def static void main(String[] args) {
		new WollokDocParser(LocalDateTime.now()).doMain(args)
	}

	override String processName() {
		"WollokDoc Parser"
	}

	/**
	 * By default WollokChecker never validates
	 */
	override shouldValidate() { true }
	
	override doConfigureParser(WollokLauncherParameters parameters) {
		injector.injectMembers(this)
		outputFolder = parameters.folder
		locale = parameters.locale.orElse(ES)
	}

	override launch(String folder, WollokLauncherParameters parameters) {
		println("Looking Wollok library in folder " + folder)
        new DirExplorer(filterWollokElements, launchWollokDocGeneration) => [
        	explore(new File(folder))
        	writeNavbar
        ]
	}
	
	def void writeNavbar() {
		val outputFolderParent = new File(outputFolder).getAbsoluteFile().getParentFile()
		val mainFile = outputFolderParent.path + "wollokDoc.md"

		println("Writing " + mainFile)
		val file = new File(mainFile)
		wollokDocFile = Files.newWriter(file, Charsets.UTF_8) => [
			write('''
				---
				layout: hyde
				title: 'WollokDoc'
				lang: 'es'
				--- 
				
				<div class="container">
				<img src="/images/documentation/wollokDoc.png" height="64" width="64" align="left" style="padding: 0px;"/>
				<br>
				<h2>&nbsp;&nbsp;Guía completa del lenguaje</h2>
				<br>
				</div>
				
				<div class="container">
				<p>
					Esta es la guía completa de las bibliotecas de objetos y clases que vienen con Wollok.
				</p>
				</div>
				
				«generateNavbar»

				<div class="tab-content card container">
					<div id="content" style="padding-top: 1rem;"/>
				</div>
				
				<script>
				selectFile("lang")
				</script>
			''')
			close
		]
	}
	
	def generateWollokDocFile(WFile file, File mainFile) {
		val lastUpdated = "Last update: " + timestamp.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"))
		file => [
			allFiles.add(mainFile)
			val htmlFile = mainFile.name.toHtmlFile
			println("Generating " + outputFolder + File.separator + htmlFile)
			wollokDocFile = Files.newWriter(new File(outputFolder + File.separator + htmlFile), Charsets.UTF_8)
			wollokDocFile
				.write('''
				<div class="container">
					«elements.forEach [ generateWollokDoc ]»
				</div>
				<p>«lastUpdated»</p>
				''')
		]
		wollokDocFile.close
	}
	
	def String toHtmlFile(String fileName) {
		fileName.replace(WollokConstants.WOLLOK_DEFINITION_EXTENSION, "html")
	}
	
	def String libraryName(String fileName) {
		fileName.split("\\.").head
	}
	
	def String generateNavbar() {
		'''
		<div class="container">
			<ul class="nav breadcrumb nav-tabs nav-justified" role="tablist">
				«allFiles.map [ file | file.generateLink ].join(" ")»
			</ul>
		</div>
		'''
	}
	
	def String generateLink(File file) {
		val libraryName = file.name.libraryName
		'''
		<li class="nav-item">
			<a id="«libraryName»" class="nav-link wollokNavLink" href="javascript:selectFile('«libraryName»')">«file.name» <span class="sr-only">(current)</span></a>
		</li>
		'''
	}
	
	def dispatch void generateWollokDoc(EObject o) {
	}

	def dispatch void generateWollokDoc(WMethodDeclaration m) {
		val comment = m.comment
		if (m.originalComment.contains(PRIVATE)) {
			privateMethods.add(m)
		} else {
			writeFile(TABLE_ROW_ON)
			val abstractDescription = if (m.abstract) badge("abstract", "light-blue") + SPACE else ""
			val nativeDescription = if (m.native) badge("native", "indigo") else ""
			writeFile("<td title=\"" + m.declaringContext.name + "\" width=\"30%\" id=\"" + m.anchor + "\">" + CODE_ON + BOLD_ON + m.name + BOLD_OFF + m.parametersAsString + CODE_OFF + SPACE +
				abstractDescription + SPACE + SPACE + nativeDescription + SPACE + TABLE_DATA_OFF +
				TABLE_DATA_ON +	comment + TABLE_DATA_OFF)
			writeFile(TABLE_ROW_OFF)
		}
	}

	def dispatch void generateWollokDoc(WVariableDeclaration v) {
		val comment = v.comment
		writeFile(TABLE_ROW_ON)
		writeFile("<td title=\"" + v.variable.name + "\" width=\"30%\">" + CODE_ON + BOLD_ON + v.variable.name + BOLD_OFF + CODE_OFF + SPACE +
			SPACE + TABLE_DATA_OFF +
			TABLE_DATA_ON +	comment + TABLE_DATA_OFF)
		writeFile(TABLE_ROW_OFF)
	}
	
	def dispatch void generateWollokDoc(WMethodContainer mc) {
		header(mc.imageName + SPACE + mc.name, mc.name)
		writeFile(showHierarchy(mc))
		mc.showComment
		val attributes = mc.variableDeclarations
		if (!attributes.isEmpty) {
			header2("Attributes")
			writeFile(TABLE_ON)
			attributes.forEach [ generateWollokDoc ]
			writeFile(TABLE_OFF)
			writeFile(HORIZONTAL_LINE)
		}
		if (!mc.methods.isEmpty) {
			header2("Behavior")
			writeFile(TABLE_ON)
			tableHeader("Method", "Description")
			writeFile(TABLE_BODY_ON)
			mc.methods.sortBy [ name ].forEach [ 
				generateWollokDoc
			]
			writeFile(TABLE_BODY_OFF)
			writeFile(TABLE_OFF)
			writeInheritedMethods(mc)
			writeFile(HORIZONTAL_LINE)
		}
		if (mc.methods.isEmpty) {
			writeFile(HORIZONTAL_LINE)
		}
	}
	
	def String showHierarchy(WMethodContainer c) {
		if (!c.hasRealParent) {
			return ""
		}
		val parent = c.parent
		return '''
		<ul>
			<li>inherits from «linkTo(parent.name, parent.file.URI.lastSegment)»</li>
			«showHierarchy(parent)»
		</ul>
		'''
	}
	
	def String linkTo(String name, String fileName) {
		'''
		<a href="javascript:selectFile('«fileName.libraryName»', '«name»')">«name»</a>
		'''
	}
	
	def String linkToMethod(String messageName, String anchor, String fileName) {
		'''
		<a href="javascript:selectFile('«fileName.libraryName»', '«anchor»')">«CODE_ON + messageName + CODE_OFF»</a>
		'''
	}
	
	def badge(String title, String color) {
		'''
		<span class="badge badge-pill «color»">«title»</span><br>
		'''
	}
	
	def String imageName(WMethodContainer container) {
		'''
		<img src="images/«container.abstractionName».png" height="24px" width="24px" title="«container.abstractionName»"/>
		'''
	}
	
	def void writeInheritedMethods(WMethodContainer mc) {
		if (!mc.hasRealParent) {
			return
		}
		val currentMc = mc.parent
		val methodsOverriden = mc.methods.filter [ overrides ].map [ name ].toList
		val inheritedMethods = currentMc
			.methods
			.filter [ 
				currentMethod | !methodsOverriden.contains(currentMethod.name) 
				&& !privateMethods.exists [ privateMethod | privateMethod.matches(currentMethod) ]
			]
			.map [ 
				linkToMethod(messageName, anchor, currentMc.declaringContext.file.URI.lastSegment)
			]
			.sort
			.join(SPACE + SPACE + "|" + SPACE + SPACE)
		card("Methods inherited from " + currentMc.name, inheritedMethods)
		writeInheritedMethods(currentMc)
	}

	def void showComment(EObject o) {
		val comment = o.comment
		if (comment !== null) {
			writeFile(PARAGRAPH_ON + SPACE + comment + PARAGRAPH_OFF)
		}
	}
	
	def String anchor(WMethodDeclaration m) {
		m.declaringContext.name + "_" + m.name + "_" + m.parameters.size
	}
	
	def void header(String text, String name) {
		writeFile(
		'''
		<h2 id="«name»">«text»</h2>
		''')
	}
	
	def void header2(String text) {
		writeFile(HEADER2_ON + SPACE + text + HEADER2_OFF)
	}
	
	def void header3(String text) {
		writeFile(HEADER3_ON + SPACE + text + HEADER3_OFF)
	}
	
	def void tableHeader(String... headers) {
		writeFile(TABLE_HEADING_CONF_ON)
		writeFile(TABLE_ROW_ON)
		headers.forEach [ writeFile(TABLE_HEADING_ON + it + TABLE_HEADING_OFF) ]
		writeFile(TABLE_ROW_OFF)
		writeFile(TABLE_HEADING_CONF_OFF)
	}

	def void card(String title, String description) {
		writeFile('''
		<div class="card card-body">
		    <h5 class="card-header blue-grey lighten-4">«title»</h5>
		    <p class="card-text">«description»</p>
		</div>
		''')
	}
	
	def String originalComment(EObject o) {
		multilineProvider.getDocumentation(o) ?: ""
	}
	
	def String comment(EObject o) {
		val comment = (multilineProvider.getDocumentation(o) ?: "").localized(locale).replace(System.lineSeparator,
			LINE_BREAK)

		wollokDocTokens.fold(comment, [ newComment, token |
			newComment.replace("@" + token, BOLD_ON + token + BOLD_OFF)
		])
	}
	
	def boolean canBeLocalized(String comment) {
		comment.startsWith("lang: ")
	}

	def String localized(String comment, String locale) {
		if(!comment.canBeLocalized()) return comment

		val expectedLocaleDeclaration = '''lang: «locale»«System.lineSeparator»'''

		val localizedComment = comment.split(LOCALIZED_COMMENT_SEPARATOR).findFirst [
			startsWith(expectedLocaleDeclaration)
		] ?: ""

		localizedComment.replace(expectedLocaleDeclaration, "")
	}

	def Filter filterWollokElements() {
		[ int level, String path, File file |
			path.endsWith(".wlk")
		]
	}
	
	def FileHandler launchWollokDocGeneration() {
		[ int level, String path, File file | 
			log.debug("Parsing program...")
			generateWollokDocFile(file.parse(null), file)
		]
	}
	
	def void writeFile(String text) {
		wollokDocFile.append(text + System.lineSeparator)
	}
}