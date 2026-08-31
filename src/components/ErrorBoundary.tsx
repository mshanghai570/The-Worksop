import React from "react";
import { AlertTriangle, RefreshCw, Trash2 } from "lucide-react";

interface Props {
  children: React.ReactNode;
  onResetProject?: () => void;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      hasError: false,
      error: null
    };
  }

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  public componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error("Uncaught Error Boundary catch:", error, errorInfo);
  }

  private handleReload = () => {
    window.location.reload();
  };

  private handleResetData = () => {
    if (this.props.onResetProject) {
      this.props.onResetProject();
    }
    this.setState({ hasError: false, error: null });
  };

  public render() {
    if (this.state.hasError) {
      return (
        <div className="w-screen h-screen bg-black text-white font-mono flex flex-col items-center justify-center p-6 text-center">
          <div className="w-16 h-16 rounded-full bg-red-950/80 border border-red-500/50 flex items-center justify-center mb-6 text-red-500 shadow-[0_0_30px_rgba(239,68,68,0.3)]">
            <AlertTriangle className="w-8 h-8" />
          </div>

          <h1 className="text-xl font-bold text-red-400 mb-2">Workspace Render Exception Recovered</h1>
          <p className="text-xs text-gray-400 max-w-md mb-6 leading-relaxed">
            An unhandled runtime error occurred during rendering. Your workspace state has been protected.
          </p>

          {this.state.error && (
            <div className="w-full max-w-lg bg-[#111] border border-[#333] rounded p-4 text-left mb-6 overflow-x-auto text-[11px] text-red-300">
              <code>{this.state.error.message || this.state.error.toString()}</code>
            </div>
          )}

          <div className="flex items-center space-x-4">
            <button
              onClick={this.handleReload}
              className="px-4 py-2 bg-[#222] hover:bg-[#333] border border-[#444] rounded text-xs font-bold text-gray-200 flex items-center space-x-2 transition-all"
            >
              <RefreshCw className="w-3.5 h-3.5" />
              <span>Reload App</span>
            </button>

            <button
              onClick={this.handleResetData}
              className="px-4 py-2 bg-[#39FF14] text-black hover:bg-green-400 rounded text-xs font-bold flex items-center space-x-2 transition-all uppercase tracking-wider"
            >
              <Trash2 className="w-3.5 h-3.5" />
              <span>Reset to Default Project</span>
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
