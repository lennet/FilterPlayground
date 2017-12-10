//
//  ASTTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 07.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class ASTTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMethod() {
        let text = "foo{ bar(); }"
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        let expectedResult = ASTNode.bracetStatement(prefix: [.identifier(.other("foo")), .openingBracket],
                                                     body: [
                                                         .statement([.whiteSpace, .identifier(.other("bar")), .identifier(.other("(")), .identifier(.other(")")), .semicolon]),
                                                         .unkown([.whiteSpace]),
                                                     ],
                                                     postfix: [.closingBracket])
        XCTAssertEqual(result, [expectedResult])
    }

    func testComment() {
        let text = "//hello world"
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        let expectedResult = ASTNode.comment(Tokenizer(string: text).getTokens())
        XCTAssertEqual(result, [expectedResult])
    }

    func testCommentAndMethod() {
        let text = "//hello world\nfoo{ bar(); }"
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        let expectedResult = [
            ASTNode.comment(Tokenizer(string: "//hello world").getTokens()),
            ASTNode.bracetStatement(prefix: [.newLine, .identifier(.other("foo")), .openingBracket],
                                    body: [
                                        .statement([.whiteSpace, .identifier(.other("bar")), .identifier(.other("(")), .identifier(.other(")")), .semicolon]),
                                        .unkown([.whiteSpace]),
                                    ],
                                    postfix: [.closingBracket]),
        ]
        XCTAssertEqual(result, expectedResult)
    }

    func testCommentInMethod() {
        let text = "foo{ //hello world\n bar(); }"
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        let expectedResult = ASTNode.bracetStatement(prefix: [.identifier(.other("foo")), .openingBracket],
                                                     body: [
                                                         .unkown([.whiteSpace]),
                                                         .comment(Tokenizer(string: "//hello world").getTokens()),
                                                         .statement([.newLine, .whiteSpace, .identifier(.other("bar")), .identifier(.other("(")), .identifier(.other(")")), .semicolon]),
                                                         .unkown([.whiteSpace]),
                                                     ],
                                                     postfix: [.closingBracket])
        XCTAssertEqual(result, [expectedResult])
    }

    func testMethodWithNewLine() {
        let text = "foo{\n}"
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        let expectedResult = ASTNode.bracetStatement(prefix: [.identifier(.other("foo")), .openingBracket],
                                                     body: [.unkown([.newLine])],
                                                     postfix: [.closingBracket])
        XCTAssertEqual(result, [expectedResult])
    }

    func testEmptyMethod() {
        let text = "foo{}"
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        let expectedResult = ASTNode.bracetStatement(prefix: [.identifier(.other("foo")), .openingBracket],
                                                     body: [],
                                                     postfix: [.closingBracket])
        XCTAssertEqual(result, [expectedResult])
    }

    func testCommentAfterSpace() {
        let text = " //Hello World\n\n}"
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        let expectedResult = [
            ASTNode.unkown([
                .whiteSpace,
            ]),
            .comment(Tokenizer(string: "//Hello World").getTokens()),
            .unkown([.newLine, .newLine]),
        ]

        XCTAssertEqual(result, expectedResult) }

    func testBrokenCommentWithNewLine() {
        let text = "/\n/hello world"
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        XCTAssertEqual(result, [ASTNode.unkown([.op(.substract), .newLine, .op(.substract), .identifier(.other("hello")), .whiteSpace, .identifier(.other("world"))])])
    }

    func testMultiLineComment() {
        let text = """
        /*
                        This is a
                        multi line comment
                    */
        """
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        XCTAssertEqual(result, [ASTNode.comment(Tokenizer(string: text).getTokens())])
    }

    func testInlineComment() {
        let text = "foo/*comment*/bar"
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        XCTAssertEqual(result, [ASTNode.unkown([.identifier(.other("foo"))]), ASTNode.comment(Tokenizer(string: "/*comment*/").getTokens()), ASTNode.unkown([.identifier(.other("bar"))])])
    }

    func testOpeningBracket() {
        let text = "{"
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        XCTAssertEqual(result, [ASTNode.bracetStatement(prefix: [.openingBracket], body: [], postfix: [])])
    }

    func testTwoOpeningBrackets() {
        let text = "{{"
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        XCTAssertEqual(result, [ASTNode.bracetStatement(prefix: [.openingBracket], body: [ASTNode.bracetStatement(prefix: [.openingBracket], body: [], postfix: [])], postfix: [])])
    }

    func testNestedEmptyBracketStatements() {
        let text = "{{}"

        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)
        let expectation: [ASTNode] = [.bracetStatement(prefix: [.openingBracket], body: [
            .bracetStatement(prefix: [.openingBracket], body:
                [], postfix: []),
        ], postfix: [.closingBracket])]

        XCTAssertEqual(result, expectation)
    }

    func testIntendationLevel() {
        let text = """
        a{b{{
                    c
                    d
            }e}}f
        """

        let tokens = Tokenizer(string: text).getTokens()
        let root = ASTNode.root(ASTHelper.getAST(for: tokens))

        let a = text.range(of: "a")!.lowerBound.encodedOffset
        let b = text.range(of: "b")!.lowerBound.encodedOffset
        let c = text.range(of: "c")!.lowerBound.encodedOffset
        let d = text.range(of: "d")!.lowerBound.encodedOffset
        let e = text.range(of: "e")!.lowerBound.encodedOffset
        let f = text.range(of: "f")!.lowerBound.encodedOffset

        XCTAssertEqual(root.intendationLevel(at: a), 0)
        XCTAssertEqual(root.intendationLevel(at: b), 1)
        XCTAssertEqual(root.intendationLevel(at: c), 3)
        XCTAssertEqual(root.intendationLevel(at: d), 3)
        XCTAssertEqual(root.intendationLevel(at: e), 2)
        XCTAssertEqual(root.intendationLevel(at: f), 0)
    }

    func testNeedsClosingBracket() {
        let text = "{ "

        let tokens = Tokenizer(string: text).getTokens()
        let root = ASTNode.root(ASTHelper.getAST(for: tokens))

        XCTAssertTrue(root.needsClosingBracket(at: 1))
    }

    func testNeedsClosingBracketFalse() {
        let text = "{ }"

        let tokens = Tokenizer(string: text).getTokens()
        let root = ASTNode.root(ASTHelper.getAST(for: tokens))

        XCTAssertFalse(root.needsClosingBracket(at: 1))
    }

    func testNeedsClosingBracketForInnerBody() {
        let text = "{{ }"

        let tokens = Tokenizer(string: text).getTokens()
        let root = ASTNode.root(ASTHelper.getAST(for: tokens))

        XCTAssertTrue(root.needsClosingBracket(at: 2))
    }

    func testNeedsClosingBracketForInnerBodyFalse() {
        let text = "{{ }}"

        let tokens = Tokenizer(string: text).getTokens()
        let root = ASTNode.root(ASTHelper.getAST(for: tokens))

        XCTAssertFalse(root.needsClosingBracket(at: 2))
    }

    func testAstInnerBracetStatementBug() {
        let text = "{{ }}"

        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)
        let expectedResult = [ASTNode.bracetStatement(prefix: [.openingBracket], body:
                [ASTNode.bracetStatement(prefix: [.openingBracket], body: [.unkown([.whiteSpace])], postfix: [.closingBracket])]
            , postfix: [.closingBracket])]

        XCTAssertEqual(expectedResult, result)
    }

    func testBrokenASTWithKernel() {
        let text = "kernel{\n\t"
        let tokens = Tokenizer(string: text).getTokens()
        let result = ASTHelper.getAST(for: tokens)

        let expectedResult: [ASTNode] = [ASTNode.bracetStatement(prefix: [.identifier(.keyword(.kernel)), .openingBracket], body: [.unkown([.newLine, .tab])], postfix: [])]

        XCTAssertEqual(result, expectedResult)
    }

    func testArgumentsForToken() {
        let tokens: [Token] = [Token.identifier(.type(.float)), Token.identifier(.other("name")), Token.identifier(.other(","))]

        let expectedResult = [KernelDefinitionArgument(index: 0, name: "name", type: KernelArgumentType.float)]
        XCTAssert(ASTHelper.arguments(for: tokens) == expectedResult)
    }

    func testKernelDefinition() {
        let source = """
        kernel vec2 hello(float radius) {
            return vec2(1.0, 1.0);
        }
        """
        let ast = Parser(string: source).getAST()
        let expectedResult = KernelDefinition(name: "hello", returnType: KernelArgumentType.vec2, arguments: [KernelDefinitionArgument(index: 0, name: "radius", type: KernelArgumentType.float)])
        let result = ast.kernelDefinition()!
        XCTAssert(result.arguments == expectedResult.arguments)
        XCTAssertEqual(result.name, expectedResult.name)
        XCTAssertEqual(result.returnType, expectedResult.returnType)
    }

    func testKernelDefinitionNoArguments() {
        let source = """
        kernel vec2 hello() {
            return vec2(1.0, 1.0);
        }
        """
        let ast = Parser(string: source).getAST()
        let expectedResult = KernelDefinition(name: "hello", returnType: KernelArgumentType.vec2, arguments: [])
        let result = ast.kernelDefinition()!
        XCTAssert(result.arguments == expectedResult.arguments)
        XCTAssertEqual(result.name, expectedResult.name)
        XCTAssertEqual(result.returnType, expectedResult.returnType)
    }

    func testKernelDefinitionMultipleArguments() {
        let source = """
        kernel vec2 hello(float radius, vec2 foo) {
            return vec2(1.0, 1.0);
        }
        """
        let ast = Parser(string: source).getAST()
        let expectedResult = KernelDefinition(name: "hello", returnType: KernelArgumentType.vec2, arguments: [KernelDefinitionArgument(index: 0, name: "radius", type: KernelArgumentType.float), KernelDefinitionArgument(index: 1, name: "foo", type: KernelArgumentType.vec2)])
        let result = ast.kernelDefinition()!
        XCTAssert(result.arguments ==
            expectedResult.arguments)
        XCTAssertEqual(result.name, expectedResult.name)
        XCTAssertEqual(result.returnType, expectedResult.returnType)
    }

    func testAstwithReplacedArguments() {
        let source = """
        kernel vec2 hello(float radius, vec2 foo) {
            return vec2(1.0, 1.0);
        }
        """
        var ast = Parser(string: source).getAST()
        ast.replaceArguments(newArguments: [KernelDefinitionArgument(index: 0, name: "bar", type: .color)])
        let result = ast.asAttributedText.string

        let expectedResult = """
        kernel vec2 hello(__color bar) {
            return vec2(1.0, 1.0);
        }
        """
        XCTAssertEqual(result, expectedResult)
    }

    func testAstwithReplacedArgumentsMultiple() {
        let source = """
        kernel vec2 hello(float radius, vec2 foo) {
            return vec2(1.0, 1.0);
        }
        """
        var ast = Parser(string: source).getAST()
        ast.replaceArguments(newArguments: [KernelDefinitionArgument(index: 0, name: "bar", type: .color), KernelDefinitionArgument(index: 1, name: "foo", type: .float)])
        let result = ast.asAttributedText.string
        let expectedResult = """
        kernel vec2 hello(__color bar, float foo) {
            return vec2(1.0, 1.0);
        }
        """
        XCTAssertEqual(result, expectedResult)
    }

    func testAstwithReplacedArgumentsWithEmptyLineBeforeDefinition() {
        let source = """

        kernel vec2 hello() {
            return vec2(1.0, 1.0);
        }
        """
        var ast = Parser(string: source).getAST()
        ast.replaceArguments(newArguments: [])
        let result = ast.asAttributedText.string
        let expectedResult = source
        XCTAssertEqual(result, expectedResult)
    }

    func testReplaceTokens() {
        let source = """

        kernel vec2 hello() {
            return hello5(1.0, 1.0);
        }
        """
        var ast = Parser(string: source).getAST()
        ast.replace(token: Token.identifier(.other("hello")), with: Token.identifier(.other("foo")))

        let expectedResult = """

        kernel vec2 foo() {
            return hello5(1.0, 1.0);
        }
        """
        XCTAssertEqual(ast.asAttributedText.string, expectedResult)
    }
}
