"""
Gemini-Style Frontend for Writing Coach
Modern chat interface with inline file upload using st.chat_input
Improved formatting and copy functionality
Cooperates with FastAPI backend (main.py)
"""

import streamlit as st
import streamlit.components.v1
import requests
import time
from typing import Optional, Dict
from datetime import datetime

# Backend configuration
BACKEND_URL = "http://localhost:8000"

def main():
    st.set_page_config(
        page_title="✨ Writing Coach - Gemini Style", 
        page_icon="✨", 
        layout="centered"
    )
    
    st.title("✨ Writing Coach - AI Evaluation Terminal")
    
    # Initialize session state for chat history
    if "messages" not in st.session_state:
        st.session_state.messages = []
    
    # Display chat history
    for message in st.session_state.messages:
        with st.chat_message(message["role"]):
            if message["role"] == "assistant" and "evaluation_data" in message:
                # Display formatted evaluation with copy button
                display_evaluation_with_copy(message["content"], message["evaluation_data"])
            else:
                st.markdown(message["content"])
            
            if "file_name" in message:
                st.info(f"📁 Attached: {message['file_name']}")
    
    # Gemini-style Chat Input with File Support
    prompt = st.chat_input(
        "Ask me to evaluate your writing or upload a file...", 
        accept_file=True, 
        file_type=["pdf", "txt", "csv", "png", "jpg", "jpeg", "md", "doc", "docx"]
    )
    
    if prompt:
        # 1. Handle User Input
        user_content = prompt.text
        attachments = prompt.files
        
        current_message = {"role": "user", "content": user_content}
        
        with st.chat_message("user"):
            st.markdown(user_content)
            if attachments:
                file_name = attachments[0].name
                current_message["file_name"] = file_name
                current_message["file_obj"] = attachments[0]
                st.info(f"📁 Uploaded: {file_name}")
        
        st.session_state.messages.append(current_message)
        
        # 2. Handle Assistant Response
        with st.chat_message("assistant"):
            response_placeholder = st.empty()
            
            # Get AI response from backend
            if attachments:
                intro_text = f"I've received your file '{attachments[0].name}'. Here's my analysis:"
                evaluation_result = process_file_upload(attachments[0])
            else:
                if user_content.strip():
                    intro_text = "Here's my evaluation of your writing:"
                    evaluation_result = process_text_input(user_content)
                else:
                    intro_text = "How can I help you evaluate your writing today? You can type text directly or upload a file for analysis."
                    evaluation_result = None
            
            # Simulate typing effect for intro
            full_intro = ""
            for chunk in intro_text.split():
                full_intro += chunk + " "
                time.sleep(0.02)
                response_placeholder.markdown(full_intro + "▌")
            
            response_placeholder.empty()
            
            # Display the response
            if evaluation_result and isinstance(evaluation_result, dict) and "error" not in evaluation_result:
                # Format and display evaluation with copy button
                formatted_content = display_evaluation_with_copy(full_intro, evaluation_result)
                complete_response = f"{full_intro}\n\n{formatted_content}"
                st.session_state.messages.append({
                    "role": "assistant", 
                    "content": complete_response,
                    "evaluation_data": evaluation_result
                })
            else:
                st.markdown(full_intro)
                if evaluation_result and isinstance(evaluation_result, dict) and "error" in evaluation_result:
                    st.error(evaluation_result["error"])
                    complete_response = f"{full_intro}\n\n❌ {evaluation_result['error']}"
                elif evaluation_result and isinstance(evaluation_result, str):
                    st.markdown(evaluation_result)
                    complete_response = f"{full_intro}\n\n{evaluation_result}"
                else:
                    complete_response = full_intro
                
                st.session_state.messages.append({
                    "role": "assistant", 
                    "content": complete_response
                })
    
    # Sidebar for additional features
    create_sidebar()


def display_evaluation_with_copy(intro_text: str, evaluation_data: dict) -> str:
    """Display evaluation results with proper formatting and copy button"""
    st.markdown(intro_text)
    st.markdown("---")
    
    # Format the evaluation data
    formatted_sections = []
    
    # Style & Topic Analysis
    style_topic = evaluation_data.get('style_and_topic', '')
    if style_topic and style_topic.strip() and style_topic != 'N/A':
        st.markdown("**🎯 Style & Topic Analysis**")
        st.markdown("")
        st.markdown(style_topic)
        st.markdown("")
        formatted_sections.append(f"Style & Topic Analysis:\n{style_topic}")
    
    # Strengths
    strengths = evaluation_data.get('strengths', [])
    if strengths:
        st.markdown("**💪 Strengths**")
        st.markdown("")
        for strength in strengths:
            st.markdown(f"• {strength}")
        st.markdown("")
        formatted_sections.append(f"Strengths:\n" + "\n".join([f"• {s}" for s in strengths]))
    
    # Areas for Improvement
    weaknesses = evaluation_data.get('weaknesses', [])
    if weaknesses:
        st.markdown("**🔍 Areas for Improvement**")
        st.markdown("")
        for weakness in weaknesses:
            st.markdown(f"• {weakness}")
        st.markdown("")
        formatted_sections.append(f"Areas for Improvement:\n" + "\n".join([f"• {w}" for w in weaknesses]))
    
    # Improvement Suggestions
    suggestions = evaluation_data.get('improvement_suggestions', [])
    if suggestions:
        st.markdown("**💡 Improvement Suggestions**")
        st.markdown("")
        for suggestion in suggestions:
            st.markdown(f"• {suggestion}")
        st.markdown("")
        formatted_sections.append(f"Improvement Suggestions:\n" + "\n".join([f"• {s}" for s in suggestions]))
    
    # Refined Version
    refined = evaluation_data.get('refined_sample', '')
    if refined and refined.strip() and refined != 'N/A':
        st.markdown("**✨ Refined Version**")
        st.markdown("")
        # Display refined text in a nice container
        st.markdown(f'<div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px; border-left: 4px solid #4CAF50;">{refined}</div>', unsafe_allow_html=True)
        st.markdown("")
        formatted_sections.append(f"Refined Version:\n{refined}")
    
    # Copy button with proper clipboard functionality
    full_text = intro_text + "\n\n" + "\n\n".join(formatted_sections)
    
    col1, col2, col3 = st.columns([1, 1, 8])
    with col1:
        copy_button_key = f"copy_{len(st.session_state.messages)}_{hash(full_text) % 10000}"
        
        # Create a unique HTML element for this copy button
        copy_html = f"""
        <div>
            <button onclick="copyToClipboard_{copy_button_key}()" 
                    style="background-color: #f0f2f6; border: 1px solid #ddd; border-radius: 6px; 
                           padding: 6px 12px; cursor: pointer; font-size: 14px;">
                📄 Copy
            </button>
            <textarea id="copyText_{copy_button_key}" style="position: absolute; left: -9999px;">{full_text}</textarea>
            <script>
            function copyToClipboard_{copy_button_key}() {{
                var copyText = document.getElementById("copyText_{copy_button_key}");
                copyText.select();
                copyText.setSelectionRange(0, 99999);
                
                try {{
                    document.execCommand("copy");
                    alert("✅ Copied to clipboard!");
                }} catch (err) {{
                    // Fallback for modern browsers
                    if (navigator.clipboard) {{
                        navigator.clipboard.writeText(copyText.value).then(function() {{
                            alert("✅ Copied to clipboard!");
                        }}).catch(function(err) {{
                            alert("❌ Copy failed. Please select and copy manually.");
                        }});
                    }} else {{
                        alert("❌ Copy failed. Please select and copy manually.");
                    }}
                }}
            }}
            </script>
        </div>
        """
        
        st.components.v1.html(copy_html, height=50)
    
    return "\n\n".join(formatted_sections)


def process_file_upload(uploaded_file) -> dict:
    """Process uploaded file and get evaluation from backend"""
    try:
        file_type = uploaded_file.type
        
        if file_type.startswith('image/'):
            # Handle image files
            result = evaluate_image_backend(uploaded_file)
            if result:
                return result
            else:
                return {"error": "Sorry, I couldn't process your image. Please make sure the backend is running and try again."}
        
        elif file_type in ['text/plain', 'application/pdf'] or uploaded_file.name.endswith(('.txt', '.md', '.csv')):
            # Handle text files
            try:
                if file_type == 'text/plain' or uploaded_file.name.endswith(('.txt', '.md', '.csv')):
                    content = str(uploaded_file.read(), "utf-8")
                    uploaded_file.seek(0)  # Reset file pointer
                    
                    result = evaluate_text_backend(content)
                    if result:
                        return result
                    else:
                        return {"error": "Sorry, I couldn't process your text. Please make sure the backend is running and try again."}
                else:
                    return {"error": "I can see you've uploaded a file, but I currently support text files (.txt, .md, .csv) and images (.png, .jpg, .jpeg) for direct processing."}
            
            except Exception as e:
                return {"error": f"Error reading file content: {str(e)}"}
        
        else:
            return {"error": f"I received your file '{uploaded_file.name}', but I currently support text files and images for direct analysis."}
    
    except Exception as e:
        return {"error": f"Error processing file: {str(e)}"}


def process_text_input(text: str) -> dict:
    """Process direct text input and get evaluation from backend"""
    try:
        result = evaluate_text_backend(text)
        if result:
            return result
        else:
            return {"error": "Sorry, I couldn't process your text. Please make sure the backend is running and try again."}
    
    except Exception as e:
        return {"error": f"Error processing text: {str(e)}"}


def evaluate_text_backend(text: str) -> Optional[dict]:
    """Send text to backend for evaluation"""
    try:
        payload = {
            "text": text,
            "user_id": "gemini_user",
            "title": "Gemini Chat Interface"
        }
        
        response = requests.post(
            f"{BACKEND_URL}/evaluate",
            json=payload,
            timeout=60
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            return None
    
    except requests.exceptions.ConnectionError:
        return None
    except Exception as e:
        return None


def evaluate_image_backend(uploaded_file) -> Optional[dict]:
    """Send image to backend for evaluation"""
    try:
        uploaded_file.seek(0)
        
        files = {
            "image": (uploaded_file.name, uploaded_file.getvalue(), uploaded_file.type)
        }
        data = {
            "user_id": "gemini_user",
            "title": "Gemini Chat Image Upload"
        }
        
        response = requests.post(
            f"{BACKEND_URL}/evaluate-image",
            files=files,
            data=data,
            timeout=120
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            return None
    
    except Exception as e:
        return None


def create_sidebar():
    """Create sidebar with settings and status"""
    with st.sidebar:
        st.header("⚙️ Settings & Status")
        
        # Backend status
        st.subheader("🔧 System Status")
        check_backend_status()
        
        # Clear conversation
        if st.button("🗑️ Clear Chat History", use_container_width=True):
            st.session_state.messages = []
            st.rerun()
        
        # Export conversation
        if st.session_state.messages:
            if st.button("💾 Export Chat", use_container_width=True):
                export_conversation()
        
        # Instructions
        st.subheader("📖 How to Use")
        st.markdown("""
        **💬 Chat Interface:**
        - Type your text directly in the chat input
        - Upload files using the 📎 attachment button
        - Get instant AI feedback and suggestions
        - Use the 📋 Copy button to copy evaluations
        
        **📁 Supported Files:**
        - Text: .txt, .md, .csv
        - Images: .png, .jpg, .jpeg
        - Documents: .pdf, .doc, .docx
        
        **✨ Features:**
        - Real-time typing animation
        - Properly formatted output with paragraphs
        - Copy to clipboard functionality
        - File attachment preview
        - Export chat history
        """)


def check_backend_status():
    """Check if backend is running"""
    try:
        response = requests.get(f"{BACKEND_URL}/health", timeout=5)
        if response.status_code == 200:
            st.success("✅ Backend Online")
            health_data = response.json()
            st.info(f"Status: {health_data.get('status', 'Running')}")
        else:
            st.error("❌ Backend Error")
    except requests.exceptions.ConnectionError:
        st.error("❌ Backend Offline")
        st.info("💡 Run: `python main.py`")
    except Exception as e:
        st.warning(f"⚠️ Status Check Failed")


def export_conversation():
    """Export conversation to file"""
    try:
        conversation_text = f"Writing Coach Conversation - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
        conversation_text += "=" * 60 + "\n\n"
        
        for message in st.session_state.messages:
            role = "You" if message['role'] == 'user' else "Writing Coach"
            conversation_text += f"{role}:\n{message['content']}\n"
            if 'file_name' in message:
                conversation_text += f"📁 Attached: {message['file_name']}\n"
            conversation_text += "\n" + "-" * 40 + "\n\n"
        
        st.download_button(
            label="📥 Download Chat History",
            data=conversation_text,
            file_name=f"writing_coach_chat_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt",
            mime="text/plain",
            use_container_width=True
        )
        st.success("✅ Chat history ready for download!")
    except Exception as e:
        st.error(f"❌ Export failed: {e}")


if __name__ == "__main__":
    main()